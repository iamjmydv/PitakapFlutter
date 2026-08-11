({String firstName, String lastName}) splitDisplayName(String? displayName) {
  final parts = (displayName ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return (firstName: '', lastName: '');
  if (parts.length == 1) return (firstName: parts.first, lastName: '');

  return (
    firstName: parts.first,
    lastName: parts.skip(1).join(' '),
  );
}
