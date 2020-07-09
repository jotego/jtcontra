#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>

using namespace std;

class K007121 {
    char cfg[64];
    int  id;
    int  bit( char v, int bpos );
    void line( int r, int bpos, const char *meaning );
public:
    K007121(const char *fname, int idcode );
    void dump();
};

int main(int argc, char *argv[]) {
    K007121 gfx1("gfx_cfg1.bin",1), gfx2("gfx_cfg2.bin",2);
    gfx1.dump();
    gfx2.dump();
    return 0;
}

K007121::K007121(const char *fname, int idcode) {
    ifstream fin(fname);
    fin.read(cfg,64);
    id = idcode;
}

int  K007121::bit( char v, int bpos ) {
    int vv =v;
    vv &= (1<<bpos);
    return vv!=0;
}

void K007121::line( int r, int bpos, const char *meaning ) {
    cout << "       " << r << "   |    "<<bpos << " | "
         << bit(cfg[r],bpos) << "       | " << meaning << '\n';
}

void K007121::dump() {
    int hpos = (((int)cfg[1]&1)<<8) | ((int)cfg[0]&0xff);
    cout << "-------------------" << id << "-----------------\n";
    cout << "Register   |  Bit | State   |  Meaning\n";
    line(1,1,"Row scroll");
    line(1,2,"Unknown");
    line(1,3,"Alternate layout ?");
    line(1,4,"Unknown");
    line(1,5,"Unknown");
    line(1,6,"Unknown");
    line(1,7,"Unknown");
    ///////
    line(3,1,"Unknown");
    line(3,2,"Unknown");
    // line(3,3,"Sprite buffer selection");
    line(3,4,"Contra layout");
    line(3,5,"Unknown");
    line(3,6,"Narrow area ?");
    line(3,7,"Unknown");
    ///////
    line(7,4,"Unknown");
    /////// Extra
    for( int k=8; k<32; k++ ) if( cfg[k] ) {
        for( int j=0; j<8; j++ )
            line(k,j,"Unknown");
    }
    // Row
    cout << "-- ROW BYTES --\n";
    for( int j=0; j<2; j++ ) {
        for( int k=0; k<16; k++ ) {
            cout << setw(2) << setfill('0') << hex << ((int)cfg[k+j*16]&0xFF) << ' ';
        }
        cout << '\n';
    }
}