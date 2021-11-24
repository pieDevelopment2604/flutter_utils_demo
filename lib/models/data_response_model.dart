import 'dart:convert';

DataResponseModel dataResponseModelFromJson(String str) => DataResponseModel.fromJson(json.decode(str));

String dataResponseModelToJson(DataResponseModel data) => json.encode(data.toJson());

class DataResponseModel {
  DataResponseModel({
    required this.data,
  });

  final List<HomePageFeedsData>? data;

  factory DataResponseModel.fromJson(Map<String, dynamic> json) => DataResponseModel(
        data: json["data"] == null ? [] : List<HomePageFeedsData>.from(json["data"].map((x) => HomePageFeedsData.fromJson(x))),
      );

  factory DataResponseModel.initial(){
    return DataResponseModel(data: []);
  }

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HomePageFeedsData {
  HomePageFeedsData({
    required this.isAComment,
    required this.commentDescription,
    required this.commentedBefore,
    required this.commentedBy,
    required this.commenterPic,
    required this.postDetails,
  });

  final bool isAComment;
  final String commentDescription;
  final String commentedBefore;
  final String commentedBy;
  final String commenterPic;
  final PostDetails? postDetails;

  factory HomePageFeedsData.fromJson(Map<String, dynamic> json) => HomePageFeedsData(
        isAComment: json["isAComment"],
        commentDescription: json["commentDescription"],
        commentedBefore: json["commentedBefore"],
        commentedBy: json["commentedBy"],
        commenterPic: json["commenterPic"],
        postDetails: json["postDetails"] == null ? null : PostDetails.fromJson(json["postDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "isAComment": isAComment,
        "commentDescription": commentDescription,
        "commentedBefore": commentedBefore,
        "commentedBy": commentedBy,
        "commenterPic": commenterPic,
        "postDetails": postDetails == null ? null : postDetails!.toJson(),
      };
}

class PostDetails {
  PostDetails({
    required this.shareCount,
    required this.commentsCount,
    required this.likesCount,
    required this.postAuthorName,
    required this.postAuthorPic,
    required this.postImage,
    required this.postDescription,
    required this.postedBefore,
  });

  final int shareCount;
  final int commentsCount;
  final int likesCount;
  final String postAuthorName;
  final String postAuthorPic;
  final String postImage;
  final String postDescription;
  final String postedBefore;

  factory PostDetails.fromJson(Map<String, dynamic> json) => PostDetails(
        shareCount: json["shareCount"],
        commentsCount: json["commentsCount"],
        likesCount: json["likesCount"],
        postAuthorName: json["postAuthorName"],
        postAuthorPic: json["postAuthorPic"],
        postImage: json["postImage"],
        postDescription: json["postDescription"],
        postedBefore: json["postedBefore"],
      );

  Map<String, dynamic> toJson() => {
        "shareCount": shareCount,
        "commentsCount": commentsCount,
        "likesCount": likesCount,
        "postAuthorName": postAuthorName,
        "postAuthorPic": postAuthorPic,
        "postImage": postImage,
        "postDescription": postDescription,
        "postedBefore": postedBefore,
      };
}
