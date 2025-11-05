class MatchingAlgorithm {
  /// Trả về điểm tương hợp (0 → 1)
  /// w1: hệ số sở thích (Interest)
  /// w2: hệ số vị trí (Location)
  /// w3: hệ số hành vi (Interaction)
  static double calculateScore({
    required int commonInterests,
    required int totalInterests,
    required double distanceKm,
    double maxDistanceKm = 50.0,
    double interactionRate = 0.0,
    double w1 = 0.5,
    double w2 = 0.3,
    double w3 = 0.2,
  }) {
    // 1️⃣ Tính độ tương đồng sở thích
    double interestSimilarity = totalInterests == 0
        ? 0
        : commonInterests / totalInterests;

    // 2️⃣ Tính độ tương đồng vị trí (giới hạn 0–1)
    double locationSimilarity =
    (1 - (distanceKm / maxDistanceKm)).clamp(0.0, 1.0);

    // 3️⃣ Hành vi tương tác (điểm hành vi)
    double interactionBehavior = interactionRate.clamp(0.0, 1.0);

    // 4️⃣ Tổng hợp điểm cuối cùng
    double score = (w1 * interestSimilarity) +
        (w2 * locationSimilarity) +
        (w3 * interactionBehavior);

    return double.parse(score.toStringAsFixed(2)); // làm tròn 2 chữ số
  }
}
