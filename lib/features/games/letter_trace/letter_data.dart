/// Letter data for the Letter Trace game
/// Contains English and Amharic alphabets with difficulty levels

class LetterData {
  final String letter;
  final String language; // 'english' or 'amharic'
  final int difficulty; // 1 = easy, 2 = medium, 3 = hard
  final String? pronunciation; // Text for TTS

  const LetterData({
    required this.letter,
    required this.language,
    required this.difficulty,
    this.pronunciation,
  });
}

/// English uppercase letters organized by difficulty
/// Easy: Simple shapes (I, L, O, C, S, etc.)
/// Medium: Moderate complexity (A, B, D, E, etc.)
/// Hard: Complex shapes (M, W, Q, K, etc.)
const List<LetterData> englishUppercaseLetters = [
  // Easy - simple strokes
  LetterData(letter: 'I', language: 'english', difficulty: 1, pronunciation: 'I'),
  LetterData(letter: 'L', language: 'english', difficulty: 1, pronunciation: 'L'),
  LetterData(letter: 'T', language: 'english', difficulty: 1, pronunciation: 'T'),
  LetterData(letter: 'O', language: 'english', difficulty: 1, pronunciation: 'O'),
  LetterData(letter: 'C', language: 'english', difficulty: 1, pronunciation: 'C'),
  LetterData(letter: 'S', language: 'english', difficulty: 1, pronunciation: 'S'),
  LetterData(letter: 'V', language: 'english', difficulty: 1, pronunciation: 'V'),
  LetterData(letter: 'X', language: 'english', difficulty: 1, pronunciation: 'X'),
  LetterData(letter: 'Z', language: 'english', difficulty: 1, pronunciation: 'Z'),
  
  // Medium - moderate complexity
  LetterData(letter: 'A', language: 'english', difficulty: 2, pronunciation: 'A'),
  LetterData(letter: 'B', language: 'english', difficulty: 2, pronunciation: 'B'),
  LetterData(letter: 'D', language: 'english', difficulty: 2, pronunciation: 'D'),
  LetterData(letter: 'E', language: 'english', difficulty: 2, pronunciation: 'E'),
  LetterData(letter: 'F', language: 'english', difficulty: 2, pronunciation: 'F'),
  LetterData(letter: 'H', language: 'english', difficulty: 2, pronunciation: 'H'),
  LetterData(letter: 'J', language: 'english', difficulty: 2, pronunciation: 'J'),
  LetterData(letter: 'K', language: 'english', difficulty: 2, pronunciation: 'K'),
  LetterData(letter: 'N', language: 'english', difficulty: 2, pronunciation: 'N'),
  LetterData(letter: 'P', language: 'english', difficulty: 2, pronunciation: 'P'),
  LetterData(letter: 'U', language: 'english', difficulty: 2, pronunciation: 'U'),
  LetterData(letter: 'Y', language: 'english', difficulty: 2, pronunciation: 'Y'),
  
  // Hard - complex shapes
  LetterData(letter: 'G', language: 'english', difficulty: 3, pronunciation: 'G'),
  LetterData(letter: 'M', language: 'english', difficulty: 3, pronunciation: 'M'),
  LetterData(letter: 'Q', language: 'english', difficulty: 3, pronunciation: 'Q'),
  LetterData(letter: 'R', language: 'english', difficulty: 3, pronunciation: 'R'),
  LetterData(letter: 'W', language: 'english', difficulty: 3, pronunciation: 'W'),
];

/// English lowercase letters
const List<LetterData> englishLowercaseLetters = [
  // Easy
  LetterData(letter: 'i', language: 'english', difficulty: 1, pronunciation: 'lowercase i'),
  LetterData(letter: 'l', language: 'english', difficulty: 1, pronunciation: 'lowercase l'),
  LetterData(letter: 'o', language: 'english', difficulty: 1, pronunciation: 'lowercase o'),
  LetterData(letter: 'c', language: 'english', difficulty: 1, pronunciation: 'lowercase c'),
  LetterData(letter: 's', language: 'english', difficulty: 1, pronunciation: 'lowercase s'),
  LetterData(letter: 'v', language: 'english', difficulty: 1, pronunciation: 'lowercase v'),
  LetterData(letter: 'x', language: 'english', difficulty: 1, pronunciation: 'lowercase x'),
  LetterData(letter: 'z', language: 'english', difficulty: 1, pronunciation: 'lowercase z'),
  
  // Medium
  LetterData(letter: 'a', language: 'english', difficulty: 2, pronunciation: 'lowercase a'),
  LetterData(letter: 'b', language: 'english', difficulty: 2, pronunciation: 'lowercase b'),
  LetterData(letter: 'd', language: 'english', difficulty: 2, pronunciation: 'lowercase d'),
  LetterData(letter: 'e', language: 'english', difficulty: 2, pronunciation: 'lowercase e'),
  LetterData(letter: 'f', language: 'english', difficulty: 2, pronunciation: 'lowercase f'),
  LetterData(letter: 'h', language: 'english', difficulty: 2, pronunciation: 'lowercase h'),
  LetterData(letter: 'j', language: 'english', difficulty: 2, pronunciation: 'lowercase j'),
  LetterData(letter: 'k', language: 'english', difficulty: 2, pronunciation: 'lowercase k'),
  LetterData(letter: 'n', language: 'english', difficulty: 2, pronunciation: 'lowercase n'),
  LetterData(letter: 'p', language: 'english', difficulty: 2, pronunciation: 'lowercase p'),
  LetterData(letter: 'u', language: 'english', difficulty: 2, pronunciation: 'lowercase u'),
  LetterData(letter: 't', language: 'english', difficulty: 2, pronunciation: 'lowercase t'),
  LetterData(letter: 'r', language: 'english', difficulty: 2, pronunciation: 'lowercase r'),
  
  // Hard
  LetterData(letter: 'g', language: 'english', difficulty: 3, pronunciation: 'lowercase g'),
  LetterData(letter: 'm', language: 'english', difficulty: 3, pronunciation: 'lowercase m'),
  LetterData(letter: 'q', language: 'english', difficulty: 3, pronunciation: 'lowercase q'),
  LetterData(letter: 'w', language: 'english', difficulty: 3, pronunciation: 'lowercase w'),
  LetterData(letter: 'y', language: 'english', difficulty: 3, pronunciation: 'lowercase y'),
];

/// Amharic Fidel (Base characters - first column of each series)
/// These are the primary consonants in their basic form
const List<LetterData> amharicLetters = [
  // First row - ሀ series (he sounds)
  LetterData(letter: 'ሀ', language: 'amharic', difficulty: 1, pronunciation: 'ha'),
  LetterData(letter: 'ለ', language: 'amharic', difficulty: 1, pronunciation: 'le'),
  LetterData(letter: 'ሐ', language: 'amharic', difficulty: 2, pronunciation: 'ha'),
  LetterData(letter: 'መ', language: 'amharic', difficulty: 1, pronunciation: 'me'),
  LetterData(letter: 'ሠ', language: 'amharic', difficulty: 2, pronunciation: 'se'),
  LetterData(letter: 'ረ', language: 'amharic', difficulty: 1, pronunciation: 're'),
  LetterData(letter: 'ሰ', language: 'amharic', difficulty: 1, pronunciation: 'se'),
  LetterData(letter: 'ሸ', language: 'amharic', difficulty: 2, pronunciation: 'she'),
  LetterData(letter: 'ቀ', language: 'amharic', difficulty: 2, pronunciation: 'qe'),
  LetterData(letter: 'በ', language: 'amharic', difficulty: 1, pronunciation: 'be'),
  LetterData(letter: 'ተ', language: 'amharic', difficulty: 1, pronunciation: 'te'),
  LetterData(letter: 'ቸ', language: 'amharic', difficulty: 2, pronunciation: 'che'),
  LetterData(letter: 'ኀ', language: 'amharic', difficulty: 3, pronunciation: 'ha'),
  LetterData(letter: 'ነ', language: 'amharic', difficulty: 1, pronunciation: 'ne'),
  LetterData(letter: 'ኘ', language: 'amharic', difficulty: 2, pronunciation: 'nye'),
  LetterData(letter: 'አ', language: 'amharic', difficulty: 1, pronunciation: 'a'),
  LetterData(letter: 'ከ', language: 'amharic', difficulty: 1, pronunciation: 'ke'),
  LetterData(letter: 'ኸ', language: 'amharic', difficulty: 2, pronunciation: 'khe'),
  LetterData(letter: 'ወ', language: 'amharic', difficulty: 1, pronunciation: 'we'),
  LetterData(letter: 'ዐ', language: 'amharic', difficulty: 2, pronunciation: 'a'),
  LetterData(letter: 'ዘ', language: 'amharic', difficulty: 1, pronunciation: 'ze'),
  LetterData(letter: 'ዠ', language: 'amharic', difficulty: 2, pronunciation: 'zhe'),
  LetterData(letter: 'የ', language: 'amharic', difficulty: 1, pronunciation: 'ye'),
  LetterData(letter: 'ደ', language: 'amharic', difficulty: 1, pronunciation: 'de'),
  LetterData(letter: 'ጀ', language: 'amharic', difficulty: 2, pronunciation: 'je'),
  LetterData(letter: 'ገ', language: 'amharic', difficulty: 1, pronunciation: 'ge'),
  LetterData(letter: 'ጠ', language: 'amharic', difficulty: 2, pronunciation: 'te'),
  LetterData(letter: 'ጨ', language: 'amharic', difficulty: 3, pronunciation: 'che'),
  LetterData(letter: 'ጰ', language: 'amharic', difficulty: 3, pronunciation: 'pe'),
  LetterData(letter: 'ጸ', language: 'amharic', difficulty: 2, pronunciation: 'tse'),
  LetterData(letter: 'ፀ', language: 'amharic', difficulty: 3, pronunciation: 'tse'),
  LetterData(letter: 'ፈ', language: 'amharic', difficulty: 2, pronunciation: 'fe'),
  LetterData(letter: 'ፐ', language: 'amharic', difficulty: 2, pronunciation: 'pe'),
];

/// Get all English letters (both uppercase and lowercase)
List<LetterData> getAllEnglishLetters() {
  return [...englishUppercaseLetters, ...englishLowercaseLetters];
}

/// Get all Amharic letters
List<LetterData> getAllAmharicLetters() {
  return [...amharicLetters];
}

/// Get letters by difficulty
List<LetterData> getLettersByDifficulty(String language, int difficulty) {
  final allLetters = language == 'amharic' 
      ? getAllAmharicLetters() 
      : getAllEnglishLetters();
  return allLetters.where((l) => l.difficulty <= difficulty).toList();
}

/// Get easy letters for beginners
List<LetterData> getEasyLetters(String language) {
  return getLettersByDifficulty(language, 1);
}

/// Get random letter from a list
LetterData getRandomLetter(List<LetterData> letters, {List<String>? exclude}) {
  final available = exclude != null
      ? letters.where((l) => !exclude.contains(l.letter)).toList()
      : letters;
  
  if (available.isEmpty) {
    // Reset if all letters have been used
    return letters[DateTime.now().millisecondsSinceEpoch % letters.length];
  }
  
  return available[DateTime.now().millisecondsSinceEpoch % available.length];
}
