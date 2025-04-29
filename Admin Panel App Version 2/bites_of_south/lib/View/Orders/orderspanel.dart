import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:bites_of_south/View/UserProfile/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CookOrderScreen extends StatefulWidget {
  const CookOrderScreen({super.key});

  @override
  _CookOrderScreenState createState() => _CookOrderScreenState();
}

class _CookOrderScreenState extends State<CookOrderScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRange;
  List<OrdersModal> _previousOrders = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showNotification = false;
  String? _newOrderId;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDateRangeChanged = false;
  String? _currentCookId;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<String> _processedOrders = {};
  late DateTime _appStartTime;
  Timer? _connectionTimer;
  bool _isOnline = true;
  final Set<String> _notifiedOrders = {};

  @override
  void initState() {
    super.initState();
    print('DEBUG: Initializing CookOrderScreen');
    _appStartTime = DateTime.now();
    print('DEBUG: App start time: $_appStartTime');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _audioPlayer
        .setSource(AssetSource('sounds/notification.mp3'))
        .catchError((e) {
      print('DEBUG: Error setting audio source: $e');
    });

    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _selectedRange = 'Today';

    // Enable Firestore synchronize for reliable offline writes
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _initializeCookId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('DEBUG: App lifecycle state changed to: $state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print('DEBUG: App paused or detached, setting offline');
      _setOffline();
    } else if (state == AppLifecycleState.resumed && !_isOnline) {
      print('DEBUG: App resumed, setting online');
      _setOnline();
    }
  }

  Future<void> _initializeCookId() async {
    print('DEBUG: Initializing cook ID');
    try {
      final prefs = await SharedPreferences.getInstance();
      final docId = prefs.getString('docId');
      setState(() {
        _currentCookId = docId;
        _isLoading = false;
      });
      if (docId != null) {
        print('DEBUG: Cook ID loaded: $docId');
        final cookDoc = await FirebaseFirestore.instance
            .collection('cooks')
            .doc(docId)
            .get();
        if (!cookDoc.exists) {
          print('DEBUG: Creating cook document for $docId');
          await FirebaseFirestore.instance.collection('cooks').doc(docId).set({
            'online': true,
            'lastActive': FieldValue.serverTimestamp(),
            'assignedOrders': [],
            'orderCount': 0,
          });
        } else {
          await FirebaseFirestore.instance
              .collection('cooks')
              .doc(docId)
              .update({
            'online': true,
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
        print('DEBUG: Cook $docId initialized');
        _listenForNewOrders();
      } else {
        print('DEBUG: No docId found in SharedPreferences');
        setState(() {
          _errorMessage = 'Cook ID not found. Please log in again.';
        });
      }
    } catch (e) {
      print('DEBUG: Error initializing cook ID: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading cook data: $e';
      });
    }
  }

  @override
  void dispose() {
    print('DEBUG: Disposing CookOrderScreen');
    if (_currentCookId != null && _isOnline) {
      FirebaseFirestore.instance
          .collection('cooks')
          .doc(_currentCookId)
          .update({
        'online': false,
        'lastActive': FieldValue.serverTimestamp(),
      }).catchError((e) {
        print('DEBUG: Error setting cook offline: $e');
      });
    }
    _connectionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _listenForNewOrders() {
    print('DEBUG: Starting listener for new orders');
    FirebaseFirestore.instance.collection('orders').snapshots().listen(
        (snapshot) {
      print(
          'DEBUG: Orders snapshot received, changes: ${snapshot.docChanges.length}');
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final orderId = change.doc.id;
          final data = change.doc.data() ;
          print('DEBUG: Order detected: $orderId, data: $data');
          if (_processedOrders.contains(orderId)) {
            print('DEBUG: Order $orderId already processed, skipping');
            continue;
          }
          if (data == null || !data.containsKey('timestamp')) {
            print('DEBUG: Order $orderId missing timestamp, skipping');
            continue;
          }
          final orderTimestamp =
              DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
          if (orderTimestamp.isBefore(_appStartTime)) {
            print(
                'DEBUG: Order $orderId is old (timestamp: $orderTimestamp), skipping');
            continue;
          }
          if (!data.containsKey('assignedCook') ||
              data['assignedCook'] == null) {
            print('DEBUG: Processing new order: $orderId');
            _processedOrders.add(orderId);
            _assignOrder(orderId);
          } else {
            print(
                'DEBUG: Order $orderId already assigned to ${data['assignedCook']}, skipping');
          }
        }
      }
    }, onError: (e) {
      print('DEBUG: Error in orders listener: $e');
      setState(() {
        _errorMessage = 'Error listening for orders: $e';
      });
    });
  }

  Future<void> _assignOrder(String orderId) async {
    if (_currentCookId == null) {
      print('DEBUG: Cannot assign order $orderId, no cook ID');
      return;
    }
    print(
        'DEBUG: Attempting to assign order: $orderId on cook: $_currentCookId');
    try {
      await Future.delayed(
          Duration(milliseconds: 100 * (_currentCookId.hashCode % 5)));
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final orderRef =
            FirebaseFirestore.instance.collection('orders').doc(orderId);
        final orderDoc = await transaction.get(orderRef);
        if (!orderDoc.exists) {
          print('DEBUG: Order $orderId does not exist');
          return;
        }
        final orderData = orderDoc.data();
        if (orderData != null && orderData['assignedCook'] != null) {
          print(
              'DEBUG: Order $orderId already assigned to ${orderData['assignedCook']}');
          return;
        }

        final cooksSnapshot = await FirebaseFirestore.instance
            .collection('cooks')
            .where('online', isEqualTo: true)
            .get();
        print('DEBUG: Found ${cooksSnapshot.docs.length} online cooks');

        final statsRef =
            FirebaseFirestore.instance.collection('stats').doc('activeCooks');
        transaction.set(
          statsRef,
          {
            'activeCookCount': cooksSnapshot.docs.length,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        print(
            'DEBUG: Updated stats with ${cooksSnapshot.docs.length} active cooks');

        if (cooksSnapshot.docs.isEmpty) {
          print('DEBUG: No online cooks available for order: $orderId');
          return;
        }

        if (cooksSnapshot.docs.length == 1) {
          final selectedCook = cooksSnapshot.docs.first;
          final orderCount = selectedCook['assignedOrders']?.length ?? 0;
          print(
              'DEBUG: Single cook ${selectedCook.id} with $orderCount orders');
          transaction.set(
            orderRef,
            {
              'assignedCook': selectedCook.id,
              'assignedAt': FieldValue.serverTimestamp(),
              'orderStatus': 'Pending',
            },
            SetOptions(merge: true),
          );
          transaction.update(
            FirebaseFirestore.instance.collection('cooks').doc(selectedCook.id),
            {
              'assignedOrders': FieldValue.arrayUnion([orderId]),
              'orderCount': orderCount + 1,
              'lastActive': FieldValue.serverTimestamp(),
            },
          );
          print(
              'DEBUG: Order $orderId assigned to single cook ${selectedCook.id}');
          return;
        }

        var selectedCook = cooksSnapshot.docs.first;
        int minOrders = selectedCook['assignedOrders']?.length ?? 0;
        for (var cook in cooksSnapshot.docs) {
          int orderCount = cook['assignedOrders']?.length ?? 0;
          if (orderCount < minOrders) {
            minOrders = orderCount;
            selectedCook = cook;
          }
        }
        print(
            'DEBUG: Selected cook: ${selectedCook.id} with $minOrders orders');

        transaction.set(
          orderRef,
          {
            'assignedCook': selectedCook.id,
            'assignedAt': FieldValue.serverTimestamp(),
            'orderStatus': 'Pending',
          },
          SetOptions(merge: true),
        );

        transaction.update(
          FirebaseFirestore.instance.collection('cooks').doc(selectedCook.id),
          {
            'assignedOrders': FieldValue.arrayUnion([orderId]),
            'orderCount': minOrders + 1,
            'lastActive': FieldValue.serverTimestamp(),
          },
        );

        print('DEBUG: Order $orderId assigned to cook ${selectedCook.id}');
      });
    } catch (e) {
      print('DEBUG: Error assigning order $orderId: $e');
      _processedOrders.remove(orderId);
    }
  }

  void _updateDateRange(DateTime? start, DateTime? end, {String? range}) {
    print(
        'DEBUG: Updating date range - start: $start, end: $end, range: $range');
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedRange = range;
      _isDateRangeChanged = true;
      _previousOrders = [];
    });
  }

  Future<void> _playSoundAndShowNotification(String orderId) async {
    print('DEBUG: Playing notification for order: $orderId');
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
      setState(() {
        _newOrderId = orderId;
        _showNotification = true;
      });
      _animationController.forward();
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _animationController.reverse();
        setState(() {
          _showNotification = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error playing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Cook Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            print('DEBUG: Navigating to ProfileScreen');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              DateRangeSection(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onDateRangeChanged: _updateDateRange,
                selectedRange: _selectedRange,
              ),
              Expanded(
                child: _buildBody(screenWidth, screenHeight),
              ),
            ],
          ),
          if (_showNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: screenHeight * 0.1,
                  color: Colors.green.withOpacity(0.9),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'New Order Assigned',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Order ID: $_newOrderId',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.025,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(double screenWidth, double screenHeight) {
    if (_isLoading) {
      print('DEBUG: Showing loading indicator');
      return Center(child: Lottie.asset('assets/loadin.json'));
    }
    if (_errorMessage != null) {
      print('DEBUG: Showing error: $_errorMessage');
      return Center(child: Text(_errorMessage!));
    }
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: StreamBuilder<QuerySnapshot>(
        stream: _buildOrdersStream(),
        builder: (context, snapshot) {
          print('DEBUG: Orders stream state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('DEBUG: Stream in waiting state');
            if (_connectionTimer == null && _isOnline) {
              print('DEBUG: Starting connection timer');
              _connectionTimer = Timer(const Duration(seconds: 5), () {
                if (mounted &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  print(
                      'DEBUG: Connection waiting for 5 seconds, setting offline');
                  _setOffline();
                }
              });
            }
            return Center(child: Lottie.asset('assets/loadin.json'));
          } else {
            if (_connectionTimer != null) {
              print('DEBUG: Canceling connection timer');
              _connectionTimer?.cancel();
              _connectionTimer = null;
            }
            if (!_isOnline) {
              print('DEBUG: Connection restored, setting online');
              _setOnline();
            }
          }

          if (snapshot.hasError) {
            print('DEBUG: Orders stream error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('DEBUG: No orders found for cook: $_currentCookId');
            return const Center(child: Text('No orders assigned'));
          }

          final orders = snapshot.data!.docs
              .map((doc) => OrdersModal.fromFirestore(doc))
              .toList();
          print(
              'DEBUG: Loaded ${orders.length} orders: ${orders.map((o) => o.id).toList()}');
          _checkForNewOrders(orders);

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                key: ValueKey(order.id),
                order: order,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onStatusUpdate: _removeOrderFromCook,
              );
            },
          );
        },
      ),
    );
  }

  void _checkForNewOrders(List<OrdersModal> currentOrders) {
    print('DEBUG: Checking for new orders, current: ${currentOrders.length}');
    if (_isDateRangeChanged) {
      _previousOrders = List.from(currentOrders);
      _isDateRangeChanged = false;
      print('DEBUG: Date range changed, resetting previous orders');
      _notifiedOrders.clear();
    }
    for (var order in currentOrders) {
      if (!_previousOrders.any((o) => o.id == order.id) &&
          !_notifiedOrders.contains(order.id)) {
        print('DEBUG: New order visible in list: ${order.id}');
        _notifiedOrders.add(order.id!);
        _playSoundAndShowNotification(order.id!);
      }
    }
    _previousOrders = List.from(currentOrders);
  }

  void _setOffline() async {
    if (_currentCookId == null || !_isOnline) return;
    try {
      await FirebaseFirestore.instance
          .collection('cooks')
          .doc(_currentCookId)
          .update({
        'online': false,
        'lastActive': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isOnline = false;
      });
      print('DEBUG: Cook $_currentCookId set to offline');
    } catch (e) {
      print('DEBUG: Error setting offline: $e');
      // Retry once after delay
      await Future.delayed(const Duration(seconds: 2));
      if (_isOnline && mounted) {
        try {
          await FirebaseFirestore.instance
              .collection('cooks')
              .doc(_currentCookId)
              .update({
            'online': false,
            'lastActive': FieldValue.serverTimestamp(),
          });
          setState(() {
            _isOnline = false;
          });
          print('DEBUG: Cook $_currentCookId set to offline on retry');
        } catch (retryError) {
          print('DEBUG: Retry failed setting offline: $retryError');
        }
      }
    }
  }

  void _setOnline() async {
    if (_currentCookId == null || _isOnline) return;
    try {
      await FirebaseFirestore.instance
          .collection('cooks')
          .doc(_currentCookId)
          .update({
        'online': true,
        'lastActive': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isOnline = true;
      });
      print('DEBUG: Cook $_currentCookId set to online');
    } catch (e) {
      print('DEBUG: Error setting online: $e');
    }
  }

  Stream<QuerySnapshot> _buildOrdersStream() {
    print('DEBUG: Building orders stream for cook: $_currentCookId');
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('assignedCook', isEqualTo: _currentCookId);
    if (_startDate != null) {
      final startMillis = _startDate!.millisecondsSinceEpoch;
      query = query.where('timestamp', isGreaterThanOrEqualTo: startMillis);
      print('DEBUG: Filtering by start date: $_startDate');
    }
    if (_endDate != null) {
      final endMillis =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
              .millisecondsSinceEpoch;
      query = query.where('timestamp', isLessThanOrEqualTo: endMillis);
      print('DEBUG: Filtering by end date: $_endDate');
    }
    query = query.orderBy('timestamp', descending: true);
    return query.snapshots();
  }

  void _removeOrderFromCook(String orderId) async {
    print('DEBUG: Removing order $orderId from cook: $_currentCookId');
    try {
      final cookRef =
          FirebaseFirestore.instance.collection('cooks').doc(_currentCookId);
      final cookDoc = await cookRef.get();
      final orderCount = (cookDoc['assignedOrders']?.length ?? 1) - 1;
      await cookRef.update({
        'assignedOrders': FieldValue.arrayRemove([orderId]),
        'orderCount': orderCount,
        'lastActive': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Order $orderId removed, new orderCount: $orderCount');
    } catch (e) {
      print('DEBUG: Error removing order $orderId: $e');
    }
  }
}

class OrderCard extends StatefulWidget {
  final OrdersModal order;
  final double screenWidth;
  final double screenHeight;
  final Function(String) onStatusUpdate;

  const OrderCard({
    required this.order,
    required this.screenWidth,
    required this.screenHeight,
    required this.onStatusUpdate,
    super.key,
  });

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String _pendingStatus;
  bool _is25Disabled = false;
  bool _is50Disabled = false;
  bool _is100Disabled = false;

  @override
  void initState() {
    super.initState();
    _pendingStatus = widget.order.pendingStatus ?? '0';
    _updateButtonStates();
    print(
        'DEBUG: OrderCard init for order: ${widget.order.id}, status: $_pendingStatus');
  }

  void _updateButtonStates() {
    _is25Disabled = _pendingStatus == '25' ||
        _pendingStatus == '50' ||
        _pendingStatus == '100';
    _is50Disabled = _pendingStatus == '50' || _pendingStatus == '100';
    _is100Disabled = _pendingStatus == '100';
  }

  Future<void> _updatePendingStatus(String status) async {
    print('DEBUG: Updating status for order ${widget.order.id} to $status');
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'pendingStatus': status});

      String orderStatus;
      if (status == '25') {
        orderStatus = 'In Progress';
      } else if (status == '50') {
        orderStatus = 'Halfway Done';
      } else {
        orderStatus = 'Completed';
        widget.onStatusUpdate(widget.order.id!);
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'orderStatus': orderStatus});

      setState(() {
        _pendingStatus = status;
        _updateButtonStates();
      });
      print('DEBUG: Status updated to $status for order ${widget.order.id}');
    } catch (e) {
      print('DEBUG: Error updating status for order ${widget.order.id}: $e');
    }
  }

  Future<void> _undoPendingStatus() async {
    print(
        'DEBUG: Undoing status for order ${widget.order.id} from $_pendingStatus');
    try {
      String previousStatus;
      String orderStatus;
      if (_pendingStatus == '100') {
        previousStatus = '50';
        orderStatus = 'Halfway Done';
      } else if (_pendingStatus == '50') {
        previousStatus = '25';
        orderStatus = 'In Progress';
      } else if (_pendingStatus == '25') {
        previousStatus = '0';
        orderStatus = 'Pending';
      } else {
        return;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
        'pendingStatus': previousStatus,
        'orderStatus': orderStatus,
      });

      setState(() {
        _pendingStatus = previousStatus;
        _updateButtonStates();
      });
      print(
          'DEBUG: Status undone to $previousStatus for order ${widget.order.id}');
    } catch (e) {
      print('DEBUG: Error undoing status for order ${widget.order.id}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: _pendingStatus == '0'
          ? Colors.white
          : _pendingStatus == '25'
              ? Colors.red.shade100
              : _pendingStatus == '50'
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
      margin: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.01),
      child: Padding(
        padding: EdgeInsets.all(widget.screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order.id ?? 'Unknown ID'}',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            ...widget.order.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.screenHeight * 0.005),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.name ?? 'Unknown Item'} x${item.quantity}',
                        style: TextStyle(fontSize: widget.screenWidth * 0.025),
                      ),
                      Text(
                        '₹${(int.parse(item.price) * item.quantity)}',
                        style: TextStyle(fontSize: widget.screenWidth * 0.025),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: widget.screenHeight * 0.01),
            Text(
              'Total: ₹${widget.order.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            Text(
              'Status: ${widget.order.orderStatus ?? 'Unknown'}',
              style: TextStyle(fontSize: widget.screenWidth * 0.025),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _is25Disabled ? null : () => _updatePendingStatus('25'),
                    child: const Text('25% Done'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(widget.screenWidth * 0.28,
                          widget.screenHeight * 0.09),
                    ),
                  ),
                  SizedBox(width: widget.screenWidth * 0.03),
                  ElevatedButton(
                    onPressed:
                        _is50Disabled ? null : () => _updatePendingStatus('50'),
                    child: const Text('50% Done'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(widget.screenWidth * 0.28,
                          widget.screenHeight * 0.09),
                    ),
                  ),
                  SizedBox(width: widget.screenWidth * 0.03),
                  ElevatedButton(
                    onPressed: _is100Disabled
                        ? null
                        : () => _updatePendingStatus('100'),
                    child: const Text('Order Completed'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(widget.screenWidth * 0.28,
                          widget.screenHeight * 0.09),
                    ),
                  ),
                ],
              ),
            ),
            if (_pendingStatus != '0' && _pendingStatus.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: widget.screenHeight * 0.01),
                child: TextButton(
                  onPressed: _undoPendingStatus,
                  child: Text(
                    'Undo',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: widget.screenWidth * 0.025,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DateRangeSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final Function(DateTime?, DateTime?, {String? range}) onDateRangeChanged;
  final String? selectedRange;

  const DateRangeSection({
    required this.screenWidth,
    required this.screenHeight,
    required this.onDateRangeChanged,
    this.selectedRange,
    super.key,
  });

  @override
  _DateRangeSectionState createState() => _DateRangeSectionState();
}

class _DateRangeSectionState extends State<DateRangeSection> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  void _selectPredefinedRange(String range) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case 'Today':
        start = now.subtract(Duration(days: 1));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Past 2 Days':
        start = now.subtract(Duration(days: 3));
        break;
      case 'This Week':
        start = now.subtract(Duration(days: 6));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        break;
      case 'This Month':
        start = now.subtract(Duration(days: 29));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        break;
      case 'All':
        start = null;
        end = null;
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onDateRangeChanged(start, end, range: range);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final maxWidth =
        isLandscape ? widget.screenWidth * 0.4 : widget.screenWidth * 0.8;
    final fontSize =
        widget.screenWidth * 0.035 > 18 ? 18.0 : widget.screenWidth * 0.035;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenHeight * 0.015,
        horizontal: widget.screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: maxWidth / 2 - widget.screenWidth * 0.015,
                child: _buildDateField(
                  context: context,
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                  fontSize: fontSize,
                ),
              ),
              SizedBox(width: widget.screenWidth * 0.03),
              SizedBox(
                width: maxWidth / 2 - widget.screenWidth * 0.015,
                child: _buildDateField(
                  context: context,
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRangeChip('Today', fontSize),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('Past 2 Days', fontSize),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Week', fontSize),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Month', fontSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.screenHeight * 0.015,
          horizontal: widget.screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: fontSize, color: Colors.green),
            SizedBox(width: widget.screenWidth * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date == null
                        ? 'Select Date'
                        : '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String range, double fontSize) {
    final isSelected = widget.selectedRange == range;
    return GestureDetector(
      onTap: () => _selectPredefinedRange(range),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.03,
          vertical: widget.screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
