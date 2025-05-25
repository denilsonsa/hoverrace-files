#pragma endian little

import std.io;
import type.base;
import type.color;

//struct Pointer {
//    str *p: u32;
//};

using Pointer = type::Hex<u32>;

using String;
fn stringFormat(String s) {
    return std::format("{:?}", s.data);
};

struct String {
    u8 len8;
    if (len8 < 0xff) {
        char data[len8];
    } else {
        u16 len16;
        if (len16 < 0xfffe) {
            char data[len16];
        } else if (len16 == 0xffff) {
            u32 len32;
            char data[len32];
        }
    }
} [[sealed, format("stringFormat")]];

struct Header {
    String title;
    padding[8];
    u32 sumValid;
    type::Hex<u32> checksum;
    u32 recordsUsed;
    u32 recordsMax;
    padding[8];
    Pointer records[recordsMax];
};

u32 MR_MAGIC_TRACK_NUMBER = 82617;
u32 MR_REGISTERED_TRACK = 0;
u32 MR_FREE_TRACK = 1;
u32 MR_NOBITMAP = 0;
u32 MR_BITMAP = 1;

struct TrackEntry {
    u32 magicNumber; // 82617
    u32 version;  // 1
    String description;
    u32 regMinor;
    u32 regMajor;
    u32 sortingIndex;
    u32 registrationMode;
    if (registrationMode == MR_FREE_TRACK) {
        u32 magicNumber2;
    }
};

struct StartingPosition {
    u32 teamIdx;
    u32 roomIdx;
    u32 x;
    u32 y;
    u32 z;
    u32 angle;
} [[single_color]];

struct Track {
    u32 numStartingPositions;
    StartingPosition startingPosition[numStartingPositions];
    u32 numRooms;
    u32 numFeatures;
    // TODO: More stuff here.
};

//struct Color {
//    u8 r [[color("FF0000")]];
//    u8 g [[color("00FF00")]];
//    u8 b [[color("0000FF")]];
//} [[hex::inline_visualize("color", r, g, b, 255)]];

struct Background {
    // Hard-coded constants:
    auto height = 2048;
    auto width = 256;

    u32 imageType;
    //Color palette[128];
    type::RGB8 palette[128];
    u8 bitmap[width * height] [[hex::visualize("bitmap", this, width/4, height)]];

    // visualize("bitmap") only supports RGBA8,
    // but we have a paletted bitmap.
} [[hex::visualize("bitmap", bitmap, width/4, height)]];

struct Sprite {
    u32 numItem;
    u32 itemHeight;
    u32 totalHeight;
    u32 width;
    u8 image[width * totalHeight] [[hex::visualize("bitmap", this, width/4, totalHeight)]];
};

struct Map {
    u32 x0;
    u32 x1;
    u32 y0;
    u32 y1;
    Sprite trackMap;
};

Header header @ 0x00;

TrackEntry entry @ header.records[0];
Track track @ header.records[1];
Background background @ header.records[2];
Map map @ header.records[3];