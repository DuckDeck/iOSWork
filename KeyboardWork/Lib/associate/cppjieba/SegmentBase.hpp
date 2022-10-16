#pragma once

#include "limonp/Logging.hpp"
#include "PreFilter.hpp"
#include <cassert>


namespace cppjieba {

const char* const SPECIAL_SEPARATORS = " \t\n\xEF\xBC\x8C\xE3\x80\x82";

using namespace limonp;

class SegmentBase {
public:
    SegmentBase() {
        XCHECK(ResetSeparators(SPECIAL_SEPARATORS));
    }
    virtual ~SegmentBase() { }

    virtual void Cut(RuneStrArray::const_iterator begin, RuneStrArray::const_iterator end, vector<WordRange>& res, bool hmm,
                     size_t max_word_len) const = 0;

    void CutToStr(const string& sentence, vector<string>& words, bool hmm = true,
                  size_t max_word_len = MAX_WORD_LENGTH) const {
        vector<Word> tmp;
        CutToWord(sentence, tmp, hmm, max_word_len);
        GetStringsFromWords(tmp, words);
    }

    void CutToWord(const string& sentence, vector<Word>& words, bool hmm = true,
                   size_t max_word_len = MAX_WORD_LENGTH) const {
        PreFilter pre_filter(symbols_, sentence);
        vector<WordRange> wrs;
        wrs.reserve(sentence.size() / 2);

        while (pre_filter.HasNext()) {
            auto range = pre_filter.Next();
            Cut(range.left, range.right, wrs, hmm, max_word_len);
        }

        words.clear();
        words.reserve(wrs.size());
        GetWordsFromWordRanges(sentence, wrs, words);
    }

    void CutRuneArray(RuneStrArray::const_iterator begin, RuneStrArray::const_iterator end, vector<WordRange>& res,
                      bool hmm = true, size_t max_word_len = MAX_WORD_LENGTH) const {
        Cut(begin, end, res, hmm, max_word_len);
    }

    bool ResetSeparators(const string& s) {
        symbols_.clear();
        RuneStrArray runes;

        if (!DecodeRunesInString(s, runes)) {
            XLOG(ERROR) << "decode " << s << " failed";
            return false;
        }

        for (size_t i = 0; i < runes.size(); i++) {
            if (!symbols_.insert(runes[i].rune).second) {
                XLOG(ERROR) << s.substr(runes[i].offset, runes[i].len) << " already exists";
                return false;
            }
        }

        return true;
    }
protected:
    unordered_set<Rune> symbols_;
}; // class SegmentBase

} // cppjieba

