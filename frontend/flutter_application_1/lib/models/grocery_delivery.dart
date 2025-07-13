class DeliveryService {
  final String id;
  final String name;
  final String logo;
  final double baseFee;
  final double serviceFee;
  final int estimatedMinutes;
  final double rating;
  final bool isAvailable;
  final String promoText;

  DeliveryService({
    required this.id,
    required this.name,
    required this.logo,
    required this.baseFee,
    required this.serviceFee,
    required this.estimatedMinutes,
    required this.rating,
    required this.isAvailable,
    this.promoText = '',
  });

  String get estimatedTime {
    if (estimatedMinutes < 60) {
      return '${estimatedMinutes} min';
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  double get totalFees => baseFee + serviceFee;
}

class GroceryOrder {
  final String id;
  final String groceryListId;
  final String serviceId;
  final String serviceName;
  final DateTime orderTime;
  final DateTime estimatedDelivery;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tip;
  final double total;
  final String? driverName;
  final String? driverPhone;
  final String deliveryAddress;

  GroceryOrder({
    required this.id,
    required this.groceryListId,
    required this.serviceId,
    required this.serviceName,
    required this.orderTime,
    required this.estimatedDelivery,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.tip,
    required this.total,
    this.driverName,
    this.driverPhone,
    required this.deliveryAddress,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Pending';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.shopping:
        return 'Shopper is Shopping';
      case OrderStatus.delivering:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusDescription {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for store confirmation';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.shopping:
        return '${driverName ?? "Your shopper"} is picking up your items';
      case OrderStatus.delivering:
        return '${driverName ?? "Driver"} is on the way';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  shopping,
  delivering,
  delivered,
  cancelled,
}

class MockDeliveryServices {
  static List<DeliveryService> getAvailableServices() {
    return [
      DeliveryService(
        id: 'instacart',
        name: 'Instacart',
        logo: '🛒',
        baseFee: 3.99,
        serviceFee: 2.50,
        estimatedMinutes: 45,
        rating: 4.8,
        isAvailable: true,
        promoText: 'Free delivery on orders 5+',
      ),
      DeliveryService(
        id: 'doordash',
        name: 'DoorDash',
        logo: '🚗',
        baseFee: 4.99,
        serviceFee: 3.00,
        estimatedMinutes: 35,
        rating: 4.7,
        isAvailable: true,
        promoText: '5 off your first order',
      ),
      DeliveryService(
        id: 'ubereats',
        name: 'Uber Eats',
        logo: '🚙',
        baseFee: 4.49,
        serviceFee: 2.75,
        estimatedMinutes: 40,
        rating: 4.6,
        isAvailable: true,
      ),
      DeliveryService(
        id: 'shipt',
        name: 'Shipt',
        logo: '🛍️',
        baseFee: 7.99,
        serviceFee: 0.00,
        estimatedMinutes: 60,
        rating: 4.9,
        isAvailable: false,
        promoText: 'Currently unavailable',
      ),
    ];
  }

  static GroceryOrder createMockOrder({
    required String groceryListId,
    required DeliveryService service,
    required double subtotal,
    required double tip,
  }) {
    return GroceryOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      groceryListId: groceryListId,
      serviceId: service.id,
      serviceName: service.name,
      orderTime: DateTime.now(),
      estimatedDelivery: DateTime.now().add(Duration(minutes: service.estimatedMinutes)),
      status: OrderStatus.pending,
      subtotal: subtotal,
      deliveryFee: service.baseFee,
      serviceFee: service.serviceFee,
      tip: tip,
      total: subtotal + service.baseFee + service.serviceFee + tip,
      deliveryAddress: '123 Main St, Your City, State 12345',
    );
  }
} 