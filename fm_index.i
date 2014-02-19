%module fm_index
%include "std_string.i"
%include "std_pair.i"
%template(SizeTPair) std::pair<size_t, size_t>; 
%{
#include "fm_index.h"
%}

// Very simple C++ example for linked list

class FMIndex {
    public:
    
        FMIndex(const std::string& filename, int sampleRate = DEFAULT_SAMPLE_RATE_SMALL);

        void verify(const std::string& bwt_filename);

        void setSampleRates(size_t largeSampleRate, size_t smallSampleRate);
        void initializeFMIndex(AlphaCount64& running_ac);

        bool updateInterval(size_t& lower, size_t& upper, char c) const;

        std::pair<size_t, size_t> findInterval(const std::string& s) const;

        size_t count(const std::string& s) const;

        inline size_t LF(size_t idx) const;
        
        inline char getChar(size_t idx) const;

        inline LargeMarker getLowerMarker(size_t position) const;

        inline LargeMarker getInterpolatedMarker(size_t target_small_idx) const;

        inline size_t getPC(char b) const;

        inline size_t getOcc(char b, size_t idx) const;

        inline AlphaCount64 getFullOcc(size_t idx) const;

        inline AlphaCount64 getOccDiff(size_t idx0, size_t idx1) const;

        inline size_t getNumStrings() const;
        inline size_t getBWLen() const;
        inline size_t getNumBytes() const;
        inline size_t getSmallSampleRate() const; 

        inline char getF(size_t idx) const;

        void printInfo() const;
        void print() const;
        void printRunLengths() const;
        
        void decodeToFile(const std::string& file);

        static const int DEFAULT_SAMPLE_RATE_LARGE = 16384;
        static const int DEFAULT_SAMPLE_RATE_SMALL = 128;
};
