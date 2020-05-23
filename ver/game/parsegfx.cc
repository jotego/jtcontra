#include <iostream>
#include <fstream>
#include <cassert>
#include <iomanip>

using namespace std;

void parse( const unsigned char* buf, const char *name );

int main( int argc, char* argv[] ) {
    unsigned char gfx1[8192];
    unsigned char gfx2[8192];

    ifstream fin("gfx1.bin",ios_base::binary);
    fin.read( (char*)gfx1, 8192 );
    fin.close();
    fin.open("gfx2.bin", ios_base::binary);
    fin.read( (char*)gfx2, 8192 );

    parse( gfx1, "GFX1" );
    parse( gfx2, "GFX2" );

    return 0;
}

void parse( const unsigned char* buf, const char *name ) {
    cout << "\n\n======================================\n";
    cout << name << '\n';
    for( int page=0; page<2; page++) {
        cout << "*************  PAGE " << page << " ************\n";
        for( int i=0x1000+0x800*page; i<0x10b0+0x800*page; i+=5 ) {
            unsigned code = buf[i];
            unsigned code_lsb = (buf[i+1]>>2)&3;
            unsigned bank = ((buf[i+4]&0xc0)>>4) | (buf[i+1]&3);
            unsigned y = buf[i+2];
            unsigned x = buf[i+3] | ( (buf[i+4]&1)<<8 );
            unsigned flipy = (buf[i+4]&0x20) != 0;
            unsigned flipx = (buf[i+4]&0x10) != 0;
            unsigned sprsize= (buf[i+4]>>1)&7;
            unsigned pal = buf[i+1]>>4;
            if( y>= 240 ) continue;
            cout << "Code\t" << hex << bank << "-" << code << "-" << code_lsb << '\n';
            cout << "Pos " << dec << x << " / " << y << "    ";
            cout << "Flip " << flipx << " / " << flipy << "    ";
            cout << "Pal " << pal << " size ";
            switch( sprsize ) {
                case 0: cout << "16x16"; break;
                case 1: cout << "16x8";  break;
                case 2: cout << "8x16";  break;
                case 3: cout << "8x8";   break;
                case 4: cout << "32x32"; break;
                default: cout << "UNKNOWN"; break;
            }
            cout << '\n';
            cout << "----------------------------------------\n";
        }
    }
}
