Map<String, dynamic> deepMapCopy(Map<String, dynamic> map) {
  Map<String, dynamic> newMap = {};
  map.forEach((key, value) {
    newMap[key] = (value is Map<String, dynamic>) ? deepMapCopy(value) : value;
  });

  return newMap;
}
