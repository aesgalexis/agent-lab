import unittest

from src.text_stats import word_count


class WordCountTests(unittest.TestCase):
    def test_counts_words_not_characters(self) -> None:
        self.assertEqual(word_count("local agents are useful"), 4)

    def test_empty_and_repeated_whitespace(self) -> None:
        self.assertEqual(word_count("   "), 0)
        self.assertEqual(word_count("one   two\nthree"), 3)


if __name__ == "__main__":
    unittest.main()
