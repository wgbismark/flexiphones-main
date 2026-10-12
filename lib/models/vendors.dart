import 'package:flexiphones/helpers/api_helper.dart';
import 'package:flexiphones/models/product_m.dart';

class VendorsResponse {
  final String status;
  final String message;
  final VendorsData vendors;

  VendorsResponse({
    required this.status,
    required this.message,
    required this.vendors,
  });

  factory VendorsResponse.fromJson(json) {
    return VendorsResponse(
      status: json['status'],
      message: json['message'],
      vendors: VendorsData.fromJson(json['vendors']),
    );
  }
}

class VendorsData {
  final List<Vendor> data;
  final String path;
  final int perPage;
  final String? nextCursor;
  final String? nextPageUrl;
  final String? prevCursor;
  final String? prevPageUrl;

  VendorsData({
    required this.data,
    required this.path,
    required this.perPage,
    this.nextCursor,
    this.nextPageUrl,
    this.prevCursor,
    this.prevPageUrl,
  });

  factory VendorsData.fromJson(json) {
    return VendorsData(
      data: List<Vendor>.from(json['data'].map((x) => Vendor.fromJson(x))),
      path: json['path'],
      perPage: json['per_page'],
      nextCursor: json['next_cursor'],
      nextPageUrl: json['next_page_url'],
      prevCursor: json['prev_cursor'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class Vendor {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? image;
  final String location;

  /// NOTE: The backend legitimately returns `null` for these when a vendor
  /// hasn't set business hours yet (confirmed in the live /v1/product/{id}
  /// response). These MUST stay nullable — treating them as non-null String
  /// crashes JSON parsing with "type 'Null' is not a subtype of type
  /// 'String'" the instant a vendor without hours is fetched, which silently
  /// aborts getProductDetails()/ProductModel.fromJson() before loadingProduct
  /// is ever reset, leaving the UI stuck on its loading shimmer forever.
  final String? openingTime;
  final String? closingTime;

  final int? pickupAvailable;
  final int? deliveryAvailable;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deletedAt;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.image,
    required this.location,
    required this.pickupAvailable,
    required this.deliveryAvailable,
    this.openingTime,
    this.closingTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phone_number']?.toString() ?? "",
      image: ApiUrls.resolveImage(json['image']),
      location: json['location'] ?? "",
      pickupAvailable: json['pickup_available'],
      deliveryAvailable: json['delivery_available'],
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      status: json['status'] ?? "unknown",
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'image': image,
      'location': location,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt,
    };
  }
}

class VendorDetails extends Vendor {
  final List<ProductModel> products;
  final List<Review> reviews;

  VendorDetails({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    super.image,
    required super.location,
    super.openingTime,
    super.closingTime,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.products,
    required this.reviews,
    required super.pickupAvailable,
    required super.deliveryAvailable,
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    return VendorDetails(
      id: json['id'],
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phone_number']?.toString() ?? "",
      image: ApiUrls.resolveImage(json['image']),
      location: json['location'] ?? "",
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
      pickupAvailable: json['pickup_available'],
      deliveryAvailable: json['delivery_available'],
      status: json['status'] ?? "unknown",
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'],
      products: json['products'] == null
          ? []
          : List<ProductModel>.from(
              json['products'].map((x) => ProductModel.fromJson(x)),
            ),
      reviews: json['reviews'] == null
          ? []
          : List<Review>.from(json['reviews'].map((x) => Review.fromJson(x))),
    );
  }
}