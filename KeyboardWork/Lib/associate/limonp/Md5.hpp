#pragma once

// Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All
// rights reserved.

// License to copy and use this software is granted provided that it
// is identified as the "RSA Data Security, Inc. MD5 Message-Digest
// Algorithm" in all material mentioning or referencing this software
// or this function.
//
// License is also granted to make and use derivative works provided
// that such works are identified as "derived from the RSA Data
// Security, Inc. MD5 Message-Digest Algorithm" in all material
// mentioning or referencing the derived work.
//
// RSA Data Security, Inc. makes no representations concerning either
// the merchantability of this software or the suitability of this
// software for any particular purpose. It is provided "as is"
// without express or implied warranty of any kind.
//
// These notices must be retained in any copies of any part of this
// documentation and/or software.



// The original md5 implementation avoids external libraries.
// This version has dependency on stdio.h for file input and
// string.h for memcpy.
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>

namespace limonp {

typedef unsigned char BYTE ;

// UINT4 defines a four byte word
typedef unsigned int UINT4;

// convenient object that wraps
// the C-functions for use in C++ only
class MD5 {
 private:
  struct __context_t {
    UINT4 state[4];                                   /* state (ABCD) */
    UINT4 count[2];        /* number of bits, modulo 2^64 (lsb first) */
    unsigned char buffer[64];                         /* input buffer */
  } context ;

  //#pragma region static helper functions
  // The core of the MD5 algorithm is here.
  // MD5 basic transformation. Transforms state based on block.
  static void MD5Transform( UINT4 state[4], unsigned char block[64] ) ;

  // Encodes input (UINT4) into output (unsigned char). Assumes len is
  // a multiple of 4.
  static void Encode( unsigned char *output, UINT4 *input, unsigned int len ) ;

  // Decodes input (unsigned char) into output (UINT4). Assumes len is
  // a multiple of 4.
  static void Decode( UINT4 *output, unsigned char *input, unsigned int len ) ;


 public:
  // MAIN FUNCTIONS
  MD5();

  // MD5 initialization. Begins an MD5 operation, writing a new context.
  void Init();

  // MD5 block update operation. Continues an MD5 message-digest
  // operation, processing another message block, and updating the
  // context.
  void Update(
    unsigned char *input,   // input block
    unsigned int inputLen ) ; // length of input block

  // MD5 finalization. Ends an MD5 message-digest operation, writing the
  // the message digest and zeroizing the context.
  // Writes to digestRaw
  void Final();

  /// Buffer must be 32+1 (nul) = 33 chars long at least
  void writeToString() ;

 public:
  // an MD5 digest is a 16-byte number (32 hex digits)
  BYTE digestRaw[ 16 ] ;

  // This version of the digest is actually
  // a "printf'd" version of the digest.
  char digestChars[ 33 ] ;

 public:
  /// Load a file from disk and digest it
  // Digests a file and returns the result.
  const char* digestFile( const char *filename );

  /// Digests a byte-array already in memory
  const char* digestMemory( BYTE *memchunk, int len ) ;

  // Digests a string and prints the result.
  const char* digestString(const char *string ) ;
};

bool md5String(const char* str, std::string& res) ;

bool md5File(const char* filepath, std::string& res) ;

}
