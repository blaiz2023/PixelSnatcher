unit main;

interface
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define jpeg} {$endif}
{$ifdef WIN64}{$define 64bit}{$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps;
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 1.00.2285 (+30)
//## Items.................... 2
//## Last Updated ............ 16apr2026, 21mar2026, 18mar2026, 15mar2026, 11mar2026, 09nov2025, 07nov2025, 31oct2025, 24oct2025, 05jun2025, 03jun2025, 01jun2025, 24may2025
//## Lines of Code............ 4,400+
//## Origin .................. Human generated and maintained
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tapp                   | tbasicapp         | 1.00.153  | 16apr2026   | App - 23mar2026, 12mar2026, 24oct2025, 01jun2025, 18mar2026, 16may2025, 12may2025
//## | tmonoicon              | tbasiccontrol     | 1.00.2102 | 16apr2026   | Pixel snatcher and tool-icon editor - 23mar2026, 18mar2026, 12mar2026, 07nov2025, 31oct2025, 24oct2025, 05jun2025, 03jun2025, 01jun2025, 16may2025, 12may2025, 06may2025
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy:boolean=false;
   iapp:tobject=nil;


const
   ilblack    =0;
   ilwhite    =1;
   ilBW       =2;
   ilcolor    =3;
   ilcolor2   =4;//dual color mode
   ilfont     =5;
   ilgrey     =6;//12mar2026
   ilrgb      =7;
   ilmax      =7;

   //file formats
   fPNG       =0;
   fICO       =1;
   fTEA       =2;
   fGIF       =3;
   fmax       =3;

   //misc
   itablimit  =15;


type
{tmonoicon}
//xxxxxxxxxxxxxxxxxxxx//111111111111111111111111111111
   tmonoicon=class(tbasicscroll)
   private

    iviewarea,icliparea:twinrect;
    iclipdownxy,iclipmovexy:tpoint;
    itabimg,itabset:tstr8;
    icapturemoveref,icaptureref64,itimer500,itimer100:comp;
    isource:trawimage;
    igrid,iimage:tbasicimage;
    irle6:tbasicrle6;
    irle8:tbasicrle8;
    irle32:tbasicrle32;
    ichangedid,itabslot,itabcount,icaptureindex2,icaptureindex,imode:longint;
    iscreen:tbasiccontrol;
    itabs,imaintoolbar,icolormodes,isettings,ioptions:tbasictoolbar;
    icolor0,icolor1,icolor2:tbasiccolor;

    //.other
    irotate,iclipactive,izoomlimit,isizelimit,imaskshades,icolors,ibytesPNG,ibytesGIF,ibytesICO,ibytesTEA,igridsize,ilastopenfilter:longint;
    imustpaint,ipreinvert,iinvert,irange,idetail,idelalpha,ialpha,idefAlpha,iflip,imirror,icanpastetab,iloaded,icancapture,ishowframe,ishowframesm,ifastcapture,ishowchecker,isourcechanged,idatachanged:boolean;
    icapturemode,icaptureref,isettingsref,ilastopenfile,ilastsavefile:string;
    iflashON:boolean;
    ipadw,ipadh,iminw,iminh,icapw,icaph,ialphaPower,ifeat,iscanTol,icolmix,iqual,ibrightness,icontrast,ishiftx,ishifty:tsimpleint;
    icaplist:array[0..(itablimit-1)] of string;

    procedure xopenimg;
    function xloadimg(s:tobject;sfilename:string):boolean;
    procedure xRGBAtoRGB(const d:tobject);//12mar2026

    procedure xclearimg;
    procedure xmakenow;//12mar2026
    function candetail:boolean;
    function canalpha:boolean;
    function xmakeimage(const d:tobject;const xindex:longint;const xdemo:boolean):boolean;
    function xmakedata(xindex,xformat:longint;xdata:pobject):boolean;
    procedure xcopybase64(xindex:longint;dformat:string);
    procedure xcopypng(xindex:longint);
    procedure xcopyarray(const xindex,ftype:longint);
    function popsaveimg(xformat:longint;var xfilename:string;xcommonfolder,xtitle2:string):boolean;
    procedure xsaveas(xindex,xformat:longint);
    procedure xonshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xonshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function lcolor(xindex:longint;xdemo:boolean):longint;
    function lcolor2(xindex:longint;xdemo:boolean):longint;
    function llabel(xindex:longint):string;
    function lhelp(xindex:longint):string;//31oct2025
    procedure setmode(x:longint);
    procedure setminw(x:longint);
    procedure setminh(x:longint);
    function getminw:longint;
    function getminh:longint;
    procedure setpadw(x:longint);
    procedure setpadh(x:longint);
    function getpadw:longint;
    function getpadh:longint;
    procedure xscreen__onpaint(sender:tobject);
    procedure xupdatebuttons;
    procedure __onclick(sender:tobject);
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    function getcapturing:boolean;
    procedure settabslot(x:longint);
    function xcapturetime:comp;

    //.tab support
    function xtabfile(const xindex:longint;const xpng:boolean):string;
    function xtabfile2(const xindex:longint;const xpng:boolean;const xsubname:string):string;
    procedure xloadtab;
    procedure xsavetab;
    procedure xsavetab2(ximage,xsettings:boolean);
    function xsettingschanged(xreset:boolean):boolean;
    function xlabelfilter(x:string):string;
    procedure xlabeltab;
    procedure xcopytab;
    procedure xpastetab;
    function gettabinfo:string;
    procedure settabinfo(x:string);
    procedure xsynccaps;
    procedure xsyncRLE;

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean); override;
    destructor destroy; override;
    function _onnotify(sender:tobject):boolean; override;
    function _onaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
    procedure _ontimer(sender:tobject); override;

    //information
    property mode:longint                 read imode          write setmode;
    property tabslot:longint              read itabslot       write settabslot;
    property minw:longint                 read getminw        write setminw;
    property minh:longint                 read getminh        write setminh;
    property padw:longint                 read getpadw        write setpadw;
    property padh:longint                 read getpadh        write setpadh;
    property showchecker:boolean          read ishowchecker   write ishowchecker;
    property fastcapture:boolean          read ifastcapture   write ifastcapture;
    property capturing:boolean            read getcapturing;
    property changedid:longint            read ichangedid;
    property tabinfo:string               read gettabinfo     write settabinfo;

    //command
    function cancmd(x:string):boolean;
    procedure cmd(x:string);

    //can
    function cansolid:boolean;
    function cancopy:boolean;
    function canpaste:boolean;
    procedure paste;
    procedure paste2;
    function cansave:boolean;
    function canresample:boolean;
    function canclear:boolean;

    //other
    procedure capture;
    procedure capturestop;
    function capturepert:longint;
    procedure clipcancel;

   end;

{tapp}
   tapp=class(tbasicapp)
   private
    icore:tmonoicon;
    itimer500:comp;
    icouldcapture,iloaded,ibuildingcontrol:boolean;
    isettingsref:string;
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;
   public
    //create
    constructor create; virtual;
    destructor destroy; override;
   end;

//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function app__syncandsavesettings:boolean;


//support procs ----------------------------------------------------------------
function mis__brightness_contrast32(s:tobject;xbrightness100,xcontrast100,xindex:longint):boolean;//09nov2025
function mis__invert32(s:tobject):boolean;//11mar2026

procedure img__clip(const d:tobject;const da:twinrect);
procedure img__makeTransparent(const d:tobject;xTol:longint);
procedure img__equalise(const d:tobject;xPower255:longint);
procedure img__effect(const d:tobject;const xindex,xcolorMix255,xalphaPower,xcolor1,xcolor2:longint;const xdetail,xalpha,xdefAlpha:boolean);
procedure img__autoInvert(const d:tobject);
procedure img__quality(const d:tobject;xQuality:longint);
procedure img__crop(const d:tobject);

procedure img__feather(const d:tobject;dfeather:longint);
procedure img__minWidthHeight(const d:tobject;const xminW,xminH:longint);
procedure img__move(const d:tobject;xmove,ymove:longint);
procedure img__pad(const d:tobject;xpad,ypad:longint);


implementation

{$ifdef gui}
uses
    gossdat;
{$endif}


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1400'
else if (xname='height')              then result:='910'

else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde
else if (xname='msstore.name')        then result:='PixelSnatcher'//optional - overrides default name for Clyde - 15apr2026

else if (xname='ver')                 then result:='1.00.2285'
else if (xname='date')                then result:='16apr2026'
else if (xname='name')                then result:='Pixel Snatcher'
else if (xname='web.name')            then result:='pixelsnatcher'//used for website name
else if (xname='des')                 then result:='Snatch screen pixels and convert into translucent tool images in PNG, GIF, ICO and TEA image formats with ease'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
try

except;end;
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

begin

//examples:
case xindex of
tepCustomBASE20 + 0 :mc( mtep_copy20 ,tep_copy20 );
tepCustomBASE20 + 1 :m( mtep_copy20              );
end;//case

end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


//support procs ----------------------------------------------------------------

procedure img__clip(const d:tobject;const da:twinrect);
var
   s:tobject;
   sw,sh,dw,dh:longint;
begin

//default
s           :=nil;

//check
if not misok32(d,sw,sh)  then exit;
if not area__valid( da ) then exit;

//clip area
dw          :=da.right  - da.left;
dh          :=da.bottom - da.top ;

if (dw<=1) and (dh<=1) then exit;

//d -> s
s           :=misimg32( sw ,sh );
miscopy(d,s);

//s -> d
missize(d ,dw ,dh );
mis__copyfast(maxarea,area__make(da.left,da.top,da.right-1,da.bottom-1),0,0,dw,dh,s,d);

//free
freeobj(@s);

end;

procedure img__makeTransparent(const d:tobject;xTol:longint);
var
   sr32:pcolorrow32;
   s32:pcolor32;
   t32:tcolor32;
   r1,r2,g1,g2,b1,b2,sx,sy,sw,sh:longint;
   xuseAlpha:boolean;

begin

//check
if not misok32(d,sw,sh) then exit;

//init
xuseAlpha   :=mask__hasTransparency32( d );
xTol        :=frcrange32(xTol-1,-1,255);

if (xTol<=-1) then exit;

t32         :=mispixel32( d ,0 ,0 );
r1          :=t32.r - xTol;
r2          :=t32.r + xTol;
g1          :=t32.g - xTol;
g2          :=t32.g + xTol;
b1          :=t32.b - xTol;
b2          :=t32.b + xTol;

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

case xuseAlpha of
true:begin

   if (s32.a<=xTol) then s32.a:=0;

   end;
else begin

   if (s32.r>=r1) and (s32.r<=r2) and
      (s32.g>=g1) and (s32.g<=g2) and
      (s32.b>=b1) and (s32.b<=b2) then
      begin

      s32.a :=0;

      end;

   end;
end;//case

end;//sx

end;//sy

end;

procedure img__equalise(const d:tobject;xPower255:longint);
var
   sr32:pcolorrow32;
   s32:pcolor32;
   v,lsize,asize,lmin,lmax,amin,amax,sx,sy,sw,sh:longint;
   lratio,aratio:double;
   xonce:boolean;

   function lscale(x:longint):longint;
   begin

   dec(x,lmin);

   if (x<=0) then x:=0;

   result:=round32(x*lratio);

   if      (result<0)   then result:=0
   else if (result>255) then result:=255;

   end;

   function ascale(x:longint):longint;
   begin

   dec(x,amin);

   if (x<0) then x:=0;

   result:=round32(x*aratio);

   if      (result<0)   then result:=0
   else if (result>255) then result:=255;

   end;

begin


//check
if (xpower255<=0)       then exit;
if not misok32(d,sw,sh) then exit;


//init
lmin        :=255;
lmax        :=0;
amin        :=255;
amax        :=0;
xonce       :=false;
xPower255   :=frcrange32(xPower255,0,255);


//scan for min-max lum
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a>=1) then
   begin

   //lum
   v        :=s32.r;
   if (s32.g>v) then v:=s32.g;
   if (s32.b>v) then v:=s32.b;

   if (v<lmin)  then lmin:=v;
   if (v>lmax)  then lmax:=v;

   //a.lum
   v        :=s32.a;

   if (v<amin) then amin:=v;
   if (v>amax) then amax:=v;

   //once
   xonce    :=true;

   end;

end;//sx

end;//sy


//check
if not xonce then exit;


//range
lsize       :=frcrange32(lmax-lmin+1,1,255);
asize       :=frcrange32(amax-amin+1,1,255);
lratio      :=255/lsize;
aratio      :=255/asize;


//stretch lum to fit lmin-lmax
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a<>0) then
   begin

   //lum
   if (lratio<255) then
      begin

      s32.r    :=( (s32.r*(255-xPower255)) + (xpower255*lscale(s32.r)) ) div 255;
      s32.g    :=( (s32.g*(255-xPower255)) + (xpower255*lscale(s32.g)) ) div 255;
      s32.b    :=( (s32.b*(255-xPower255)) + (xpower255*lscale(s32.b)) ) div 255;

      end;

   if (aratio<255) then
      begin

      s32.a    :=( (s32.a*(255-xPower255)) + (xpower255*ascale(s32.a)) ) div 255;//requires the accuracy

      if (s32.a=0) then s32.a:=1;

      end;

   end;

end;//sx

end;//sy

end;

procedure img__effect(const d:tobject;const xindex,xcolorMix255,xalphaPower,xcolor1,xcolor2:longint;const xdetail,xalpha,xdefAlpha:boolean);
var
   sr32:pcolorrow32;
   c1,c2:tcolor32;
   s32:pcolor32;
   xgrey,xcolMix,v,v2,sx,sy,sw,sh:longint;
   ychecker,xchecker:boolean;

   function valphaPower(const v:byte):longint;
   begin

   result:=(v * xalphaPower) div 100;
   if      (result<0)   then result:=0
   else if (result>255) then result:=255;

   end;

   procedure vgrey;
   begin

   v        :=(  ( c32__lum(s32^)*(255-xgrey) ) + ( ((s32.r+s32.g+s32.b) div 3)*xgrey )  ) shr 8;

   if (v<=0) then v:=1;

   end;

   procedure vwhite;
   begin

   vgrey;

   case xalpha of
   true:begin

      s32.r :=255;
      s32.g :=255;
      s32.b :=255;
      s32.a :=valphaPower(v);

      end;
   else begin

      s32.r :=( (255*v) + (128*(255-v)) ) shr 8;
      s32.g :=( (255*v) + (128*(255-v)) ) shr 8;
      s32.b :=( (255*v) + (128*(255-v)) ) shr 8;
      if xdefAlpha then s32.a :=255;

      end;
   end;//case

   end;

   procedure vblack;
   begin

   vgrey;

   case xalpha of
   true:begin

      s32.r :=0;
      s32.g :=0;
      s32.b :=0;
      s32.a :=valphaPower(v);

      end;
   else begin

      s32.r :=( (127*(255-v)) + (10*v) ) shr 8;
      s32.g :=( (127*(255-v)) + (10*v) ) shr 8;
      s32.b :=( (127*(255-v)) + (10*v) ) shr 8;
      if xdefAlpha then s32.a :=255;

      end;
   end;//case

   end;

   procedure vcolor;
   begin

   vgrey;

   case xalpha of
   true:begin

      s32.r :=c1.r;
      s32.g :=c1.g;
      s32.b :=c1.b;
      s32.a :=valphaPower(v);

      end;
   else begin

      s32.r :=( (c1.r*v) + (0*(255-v)) ) shr 8;
      s32.g :=( (c1.g*v) + (0*(255-v)) ) shr 8;
      s32.b :=( (c1.b*v) + (0*(255-v)) ) shr 8;
      if xdefAlpha then s32.a :=255;

      end;
   end;//case

   end;

begin

//check
if not misok32(d,sw,sh) then exit;

//init
xgrey       :=insint(255,xdetail);
xcolMix     :=frcrange32(xcolorMix255,1,255);
c1          :=int__c32(xcolor1);
c2          :=int__c32(xcolor2);
ychecker    :=false;

//get
for sy:=0 to pred(sh) do
begin

ychecker    :=not ychecker;
xchecker    :=ychecker;
if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a<>0) then
   begin

   case xindex of

   ilWhite:vwhite;

   ilBlack:vblack;

   ilBW:begin

      case xchecker of
      true:vwhite;
      else vblack;
      end;//case

      end;

   ilColor:vcolor;

   ilColor2:begin

      vgrey;

      v2    :=(v*xcolMix) shr 8;

      s32.r :=((( (c1.r*(255-v2)) + (c2.r*v2) ) shr 8)*v) shr 8;
      s32.g :=((( (c1.g*(255-v2)) + (c2.g*v2) ) shr 8)*v) shr 8;
      s32.b :=((( (c1.b*(255-v2)) + (c2.b*v2) ) shr 8)*v) shr 8;

      case xalpha of
      true:s32.a :=valphaPower( v );
      else if xdefAlpha then s32.a :=255;
      end;//case

      end;

   ilFont:begin

      vgrey;
      vcolor;

      end;

   ilGrey:begin

      vgrey;

      s32.r :=v;
      s32.g :=v;
      s32.b :=v;

      case xalpha of
      true:s32.a :=valphaPower( v );
      else if xdefAlpha then s32.a :=255;
      end;//case

      end;

   ilRGB:begin

      vgrey;

      case xalpha of
      true:s32.a :=valphaPower( v );
      else if xdefAlpha then s32.a:=255;
      end;//case
      
      end;

   end;//case

   end;

//xchecker
xchecker    :=not xchecker;

end;//sx

end;//sy

end;

procedure img__autoInvert(const d:tobject);
var
   sr32:pcolorrow32;
   s32:pcolor32;
   vgood,vcount,sx,sy,sw,sh,v:longint;
   vgood2:double;
   xonce:boolean;

begin


//check
if not misok32(d,sw,sh) then exit;


//init
xonce       :=false;
vgood       :=0;
vcount      :=0;


//scan
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a<>0) then
   begin

   //lum
   v        :=s32.r;
   if (s32.g>v) then v:=s32.g;
   if (s32.b>v) then v:=s32.b;

   if (v>=200)  then inc(vgood);

   inc(vcount);

   //once
   xonce    :=true;

   end;

end;//sx

end;//sy


//get
vgood2:=(vgood/frcmin32(vcount,1));


//check - no visible pixels -> nothing to do -> exit
if not xonce     then exit;


//check - 10% (0.1) or more pixels bright -> this is considered sufficent to work with -> no need to invert image
if (vgood2>=0.1) then exit;


//invert
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a<>0) then
   begin

   s32.r    :=255-s32.r;
   s32.g    :=255-s32.g;
   s32.b    :=255-s32.b;

   end;

end;//sx

end;//sy

end;

procedure img__quality(const d:tobject;xQuality:longint);
const
   xdivval  =25;
   xlimit   =100;
var
   sr32:pcolorrow32;
   s32:pcolor32;
   sx,sy,sw,sh:longint;

begin

//check
if (xQuality>=xlimit)   then exit;
if not misok32(d,sw,sh) then exit;

//init
xQuality    :=frcrange32(xQuality,1,xlimit);

//get
for sy:=0 to pred(sh) do
begin

if not misscan32(d,sy,sr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx];

if (s32.a<>0) then
   begin

   s32.r    :=((s32.r*xQuality) + ((s32.r div xdivval)*xdivval*(xlimit-xQuality))) div xlimit;
   s32.g    :=((s32.g*xQuality) + ((s32.g div xdivval)*xdivval*(xlimit-xQuality))) div xlimit;
   s32.b    :=((s32.b*xQuality) + ((s32.b div xdivval)*xdivval*(xlimit-xQuality))) div xlimit;
   s32.a    :=((s32.a*xQuality) + ((s32.a div xdivval)*xdivval*(xlimit-xQuality))) div xlimit;

   if (s32.a<=0) then s32.a:=1;

   end;

end;//sx

end;//sy

end;

procedure img__crop(const d:tobject);
var
   s:tobject;
   sr32:pcolorrow32;
   x1,x2,y1,y2,sw,sh:longint;

   procedure xscan;
   var
      sx,sy:longint;
      xcolorDetected:boolean;
   begin

   //scan
   for sy:=0 to pred(sh) do
   begin

   if not misscan32(s,sy,sr32) then exit;

   xcolorDetected     :=false;

   for sx:=0 to pred(sw) do
   begin

   if (sr32[sx].a>=1) then
      begin

      xcolorDetected  :=true;

      //.x1 - left
      if (sx<x1) then x1:=sx;

      //.x2 - right
      if (sx>x2) then x2:=sx;

      end;

   end;//sx

   //.y1 and y2
   if xcolorDetected then
      begin

      //.y1 - top
      if (sy<y1) then y1:=sy;

      //.y2 - bottom
      if (sy>y2) then y2:=sy;

      end;

   end;//sy

   end;

begin

//defaults
s           :=nil;

//check
if not misok32(d,sw,sh) then exit;

//init
x1          :=max32;
x2          :=min32;
y1          :=max32;
y2          :=min32;

//d -> s
s           :=misimg32( sw ,sh );
miscopy(d,s);

//scan
xscan;

if (x1>=max32) then x1:=0;
if (x2<=min32) then x2:=sw-1;
if (y1>=max32) then y1:=0;
if (y2<=min32) then y2:=sh-1;

//size
missize( d ,x2-x1+1 ,y2-y1+1 );//always 1x1 or larger

//s -> d
mis__copyfast(maxarea ,area__make( x1 ,y1 ,x2 ,y2) ,0 ,0 ,x2-x1+1 ,y2-y1+1 ,s ,d);

//free
freeobj(@s);

end;

procedure img__feather(const d:tobject;dfeather:longint);
label
   skipend;

var
   s:tbasicimage;
   sr32,dr32:pcolorrows32;
   d32:pcolor32;
   dpower255,r,g,b,a,c,sx,sy,sw,sh:longint;
   mall,dfeatherAll:boolean;

   procedure dcol;
   var
      va:longint;
   begin

   //defaults
   r        :=0;
   g        :=0;
   b        :=0;
   a        :=0;
   c        :=0;
   mall     :=false;

   //check
   if (sr32[sy][sx].a>=1) then
      begin

      case dfeatherAll of
      true:begin

         mall  :=true;
         va    :=sr32[sy][sx].a;
         inc( r ,sr32[sy][sx].r*va );
         inc( g ,sr32[sy][sx].g*va );
         inc( b ,sr32[sy][sx].b*va );
         inc( a ,va );
         inc( c ,1  );

         end;
      else exit;
      end;//case

      end;

   //get
   //.left
   if (sx>=1) and (sr32[sy][sx-1].a>=1) then
      begin

      va    :=sr32[sy][sx-1].a;
      inc( r ,sr32[sy][sx-1].r*va );
      inc( g ,sr32[sy][sx-1].g*va );
      inc( b ,sr32[sy][sx-1].b*va );
      inc( a ,va );
      inc( c ,1  );

      end;

   //.right
   if (sx<pred(sw)) and (sr32[sy][sx+1].a>=1) then
      begin

      va    :=sr32[sy][sx+1].a;
      inc( r ,sr32[sy][sx+1].r*va );
      inc( g ,sr32[sy][sx+1].g*va );
      inc( b ,sr32[sy][sx+1].b*va );
      inc( a ,va );
      inc( c ,1  );

      end;

   //.top
   if (sy>=1) and (sr32[sy-1][sx].a>=1) then
      begin

      va    :=sr32[sy-1][sx].a;
      inc( r ,sr32[sy-1][sx].r*va );
      inc( g ,sr32[sy-1][sx].g*va );
      inc( b ,sr32[sy-1][sx].b*va );
      inc( a ,va );
      inc( c ,1  );

      end;

   //.bottom
   if (sy<pred(sh)) and (sr32[sy+1][sx].a>=1) then
      begin

      va    :=sr32[sy+1][sx].a;
      inc( r ,sr32[sy+1][sx].r*va );
      inc( g ,sr32[sy+1][sx].g*va );
      inc( b ,sr32[sy+1][sx].b*va );
      inc( a ,va );
      inc( c ,1  );

      end;

   end;

begin


//defaults
s           :=nil;
c           :=0;

//range
dfeather    :=frcrange32(dfeather,-255,255);
dfeatherAll :=(dfeather<=0);

//check
if (dfeather=0)         then exit;
if not misok32(d,sw,sh) then exit;

try

//init
s           :=misimg32(1,1);

if not miscopy(d,s)       then goto skipend;

if not misrows32(s,sr32)  then goto skipend;

if not misrows32(d,dr32)  then goto skipend;

dpower255   :=low__posn(dfeather);

//get
for sy:=0 to pred(sh) do
begin

for sx:=0 to pred(sw) do
begin

dcol;

if (c>=1) then
   begin

   d32      :=@dr32[sy][sx];
   r        :=r div a;
   g        :=g div a;
   b        :=b div a;

   case mall of

   true:begin

      a        :=a div c;
      d32.r    :=( ((255-dpower255)*d32.r) + (dpower255*r) ) shr 8;
      d32.g    :=( ((255-dpower255)*d32.g) + (dpower255*g) ) shr 8;
      d32.b    :=( ((255-dpower255)*d32.b) + (dpower255*b) ) shr 8;
      d32.a    :=( ((255-dpower255)*d32.a) + (dpower255*a) ) shr 8;

      end;

   else begin

      a        :=((a*dpower255) div c) shr 8;
      d32.r    :=r;
      d32.g    :=g;
      d32.b    :=b;
      d32.a    :=a;

      end;

   end;//case

   end;

end;//sx

end;//sy

skipend:
except;end;

//free
freeobj(@s);

end;

procedure img__minWidthHeight(const d:tobject;const xminW,xminH:longint);
var
   s:tobject;
   sw,sh,dw,dh:longint;
begin

//default
s           :=nil;

//check
if not misok32(d,sw,sh)  then exit;

//range
dw          :=frcmin32(sw ,frcmin32(xminW,1) );
dh          :=frcmin32(sh ,frcmin32(xminH,1) );

if (sw=dw) and (sh=dh) then exit;


//d -> s
s           :=misimg32( sw ,sh );
miscopy(d,s);

//s -> d
missize(d ,dw ,dh );
mis__cls( d ,0 ,0 ,0 ,0 );
mis__copyfast(maxarea,misarea(s),(dw-sw) div 2,(dh-sh) div 2,sw,sh,s,d);

//free
freeobj(@s);

end;

procedure img__move(const d:tobject;xmove,ymove:longint);
var
   s:tobject;
   sw,sh:longint;
begin

//defaults
s           :=nil;

//check
if not misok32(d,sw,sh) then exit;

//init
xmove       :=frcrange32(xmove,-128,128);
ymove       :=frcrange32(ymove,-128,128);

//check
if (xmove=0) and (ymove=0) then exit;

//d -> s
s           :=misimg32( sw ,sh );
miscopy(d,s);

//cls
mis__cls( d ,0 ,0 ,0 ,0 );

//s -> d
mis__copyfast(maxarea ,misarea(s) ,xmove ,ymove ,sw ,sh ,s ,d );

//free
freeobj(@s);

end;

procedure img__pad(const d:tobject;xpad,ypad:longint);
var
   s:tobject;
   sw,sh:longint;
begin

//defaults
s           :=nil;

//check
if not misok32(d,sw,sh) then exit;

//init
xpad        :=frcmin32(xpad,0);
ypad        :=frcmin32(ypad,0);

//check
if (xpad<=0) and (ypad<=0) then exit;

//d -> s
s           :=misimg32( sw ,sh );
miscopy(d,s);

//s -> d
missize( d ,sw + (2*xpad) , sh + (2*ypad) );
mis__cls( d ,0 ,0 ,0 ,0 );

mis__copyfast(maxarea,misarea(s),xpad,ypad,sw,sh,s,d);

//free
freeobj(@s);

end;


//## tmicon ####################################################################

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//1111111111111111111111111
constructor tmonoicon.create2(xparent:tobject;xscroll,xstart:boolean);
const
   vsep         =7;
   vlabelratio  =0;
   vcontrolratio=0.4;//.6;
   scale_tabs=0.80;
   scale_mode=0.93;
   scale_opts=0.92;
   scale_vpad=0;
var
   s,sx,sy,sw,sh,p:longint;
   sr32:pcolorrow32;
   c0,c1:tcolor32;
   xfirst,ybol,bol1:boolean;
   icurrentcol,icurrentsubcol:tbasicscroll;

   function xnewcol(xindex,xremcount:longint;xscroll:boolean):tbasicscroll;
   begin
   self.xcols.remcount[xindex]:=xremcount;
   result:=self.xcols.cols2[xindex,1,xscroll];
   //debug: result.bordersize:=2;
   icurrentcol:=result;
   icurrentsubcol:=result;
   xfirst:=true;
   end;

   function xlabel(xcap,xhelp:string):tbasictitle;
   begin
   result:=icurrentsubcol.ntitle(false,xcap,xhelp);
   result.normal:=true;
   result.obold    :=true;
   result.oflatback:=true;
   result.oindent  :=false;
   if xfirst then result.osepv:=0 else result.osepv:=round(vlabelratio*vsep);
   xfirst:=false;
   end;

   function sint(xcap,xhelp:string;xmin,xmax,xdef,xval:longint):tsimpleint;
   begin
   result:=icurrentsubcol.mint(xcap,xhelp,xmin,xmax,xdef,xval);
   if not xfirst then result.osepv:=round(vcontrolratio*vsep);
   xfirst:=false;
   end;

   function xnewsubcols(slabel,shelp:string):tbasiccols;
   begin
   icurrentsubcol:=icurrentcol;
   if (slabel<>'') then xlabel(slabel,shelp);
   result:=icurrentcol.ncols;
   result.makeautoheight;
   end;

   function xhelpval(const x:string):string;
   begin

   if      (x='micon.copy.array.tea')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in 32 bit TEA format. Image data can be directly included into any Gossamer app source code.'
   else if (x='micon.copy.array.png')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in PNG format.'
   else if (x='micon.copy.array.gif')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in GIF format.'
   else if (x='micon.copy.array.ico')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in ICO format.'
   else if (x='micon.copy.b64.png')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format PNG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
   else if (x='micon.copy.b64.ico')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format ICO. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
   else if (x='micon.copy.b64.gif')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format GIF. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'+xhelpval('gif.restriction')
   else if (x='micon.capture')         then result:='Capture image from screen|Hold down this button and drag to capture screen in realtime without delay, alternatively, click this button and hover '+'your cursor at the capture location, holding it still for capture to automatically complete after a short delay'
   else if (x='gif.restriction')       then result:='|*|'+'Format Restriction|The GIF image format can only store 2 mask values (on and off) and 256 colors. An image with subtle mask values, or 2 or more, or more than 256 colors may appear incorrectly.'
   else if (x='micon.copy.png')        then result:='Copy|Copy image to Clipboard'
   else if (x='micon.paste')           then result:='Paste|Paste image from Clipboard'
   else if (x='micon.paste2')          then result:='Paste 2|Paste, convert and copy image to Clipboard as a Pascal array in PNG format'
   else
      begin
      result:='';
      //showbasic('Undefined help.val');
      end;

   end;

begin
//self
inherited create2(xparent,xscroll,false);

//var
iloaded          :=false;
imustpaint       :=false;
bordersize       :=0;
oautoheight      :=true;
itimer500        :=0;
itimer100        :=0;
ilastopenfile    :='';
ilastopenfilter  :=0;
ilastsavefile    :='';
iflashON         :=false;
izoomlimit       :=15;
isizelimit       :=256;//was: 128 - 15apr2026
igridsize        :=2;
ibytesPNG        :=0;
ibytesGIF        :=0;
ibytesICO        :=0;
ibytesTEA        :=0;
icolors          :=0;
imaskshades      :=0;
idatachanged     :=false;
ifastcapture     :=false;
ishowchecker     :=true;
ishowframe       :=true;
ishowframesm     :=true;
isettingsref     :='';
icaptureref      :='';
xfirst           :=true;
icapturemode     :='';
icancapture      :=false;
icaptureref64    :=0;
icapturemoveref  :=0;
itabslot         :=0;
icanpastetab     :=false;
itabimg          :=str__new8;
itabset          :=str__new8;
icliparea        :=nilarea;
iviewarea        :=nilarea;//area of enlarged view
iclipactive      :=0;
imirror          :=false;
iflip            :=false;
ipreinvert       :=false;
iinvert          :=false;
irange           :=false;
idetail          :=false;
ialpha           :=false;
idefAlpha        :=false;
idelalpha        :=false;
irotate          :=0;

//images
isource      :=misraw32(1,1);//resizable
iimage       :=misimg32(1,1);
irle6        :=tbasicrle6.create;
irle8        :=tbasicrle8.create;
irle32       :=tbasicrle32.create;

//.grid
c0:=rgba__c32(128,128,128,100);
c1:=rgba__c32(255,255,255,200);

sw:=(isizelimit+igridsize)*izoomlimit;
sh:=(isizelimit+igridsize)*izoomlimit;
igrid:=misimg32(sw,sh);

bol1:=false;//18may2025
for sy:=0 to (sh-1) do
begin
if not misscan32(igrid,sy,sr32) then break;
ybol:=low__iseven(sy div 2);

for sx:=0 to (sw-1) do
begin
if low__iseven(sx) then bol1:=not bol1;
if bol1 xor ybol then sr32[sx]:=c0 else sr32[sx]:=c1;
end;//sx

end;//sy

//.info slots
with xnewcol(0,40,true).client do
begin

xlabel('Tab Options','');
itabs:=ntoolbar('');

with itabs do
begin
normal:=true;
ounderline :=false;
oflatback  :=true;
oheadalign:=false;
halign:=0;
oscaleh   :=scale_tabs;
oscalevpad:=scale_vpad;

add('Copy Tab',tepCopy20,0,'micon.copytab','Work Tab|Copy active work tab contents (image + settings) to internal Clipboard');
newline;

add('Paste Tab',tepPaste20,0,'micon.pastetab','Work Tab|Paste internal Clipboard contents (image + settings) to active work tab');
newline;

add('Edit Caption',tepTXT20,0,'micon.labeltab','Work Tab|Customise active work tab caption');
newline;


add('Work Tabs',tepNone,0,'micon.worktabs','');
btitle2['micon.worktabs']:=true;
newline;


for p:=0 to (itablimit-1) do
begin

icaplist[p]:='';
add('',tepYesBlank20,0,'micon.tabslot.'+intstr32(p),'Work Tab|Customise capture settings and image options per tab|Select to work with this tab');
newline;

end;//p

end;
end;


//.image display
//with xnewcol(1,120,false).client do
with xnewcol(1,120,false) do
begin

with client do
begin
iscreen:=ncontrol;
iscreen.oautoheight:=true;
iscreen.bordersize:=10;
end;

end;


//.color modes etc
with xnewcol(2,27,true).client do
begin

xlabel('Color Mode','');
icolormodes:=ntoolbar('');

with icolormodes do
begin
normal:=true;
ounderline :=false;
oflatback  :=true;
oheadalign:=false;
halign:=0;
oscaleh   :=scale_mode;
oscalevpad:=scale_vpad;

for p:=0 to ilmax do
   begin
   add(llabel(p),tepYesBlank20,0,'micon.mode.'+intstr32(p),'Color Mode|'+lhelp(p));
   newline;
   end;

end;//color modes

xlabel('Settings','');
isettings:=ntoolbar('');

with isettings do
begin
normal:=true;
ounderline :=false;
oflatback  :=true;
oheadalign:=false;
halign:=0;
oscaleh   :=scale_mode;
oscalevpad:=scale_vpad;

add('Fast Capture',tepYesBlank20,0,'micon.fastcapture','Fast Capture|Toggle between standard capture time and fast capture time for delayed capture mode (click and hold cursor to capture)');
newline;

add('Checker',tepYesBlank20,0,'micon.checker','Checkboard|Toggle animated checkerboard background for transparent regions of Enlarged View');
newline;

add('Frame Enlarged',tepYesBlank20,0,'micon.frame','Frame|Toggle image boundary frame for Enlarged View');
newline;

add('Frame Actual',tepYesBlank20,0,'micon.framesm','Frame|Toggle image boundary frame for Actual Views (actual size 100%)');
newline;

add('Swap Colors',tepRefresh20,0,'micon.swapcols','Colors|Swap colors');
newline;
end;

icolor0:=ncolor('Color','');

with icolor0 do
begin

opopcolor   :=true;
oshaderange :=false;
caption     :='Color';
osleek      :=false;

end;

icolor1:=ncolor('Color','');

with icolor1 do
begin

opopcolor   :=true;
oshaderange :=false;
caption     :='Color 1';
osleek      :=false;

end;

icolor2:=ncolor('Color','');

with icolor2 do
begin

opopcolor   :=true;
oshaderange :=false;
caption     :='Color 2';
osleek      :=false;

end;

end;//column


//.capture settings etc
with xnewcol(3,60,true).client do
begin

with xnewsubcols('Image and Capture Dimensions','') do
begin
iminw:=sint('Minimum Width','',1,isizelimit,10,10);
iminh:=sint('Minimum Height','',1,isizelimit,20,20);

icapw:=sint('Capture Width','',5,isizelimit,40,40);
icaph:=sint('Capture Height','',5,isizelimit,40,40);

with xnewsubcols('Padding and Offset','') do
begin
icurrentsubcol:=makecol(0,50,false);
ipadw:=sint('H-Pad','H-Pad|Insert transparent padding either side of image',0,30,1,1);
ishiftx:=sint('H-Move','H-Move|Move image left or right',-30,30,0,0);

icurrentsubcol:=makecol(1,50,false);
ipadh:=sint('V-Pad','V-Pad|Insert transparent padding above and below image',0,30,0,0);
ishifty:=sint('V-Move','V-Move|Move image up or down',-30,30,0,0);
end;

icurrentsubcol:=icurrentcol;

xlabel('Color Conversion Settings','');
iscanTol    :=sint('Scan Tolerance','Scan Tolerance|Adjust scan tolerance to remove background pixels',0,255,30,30);
ibrightness :=sint('Brightness','Brightness|Adjust image brightness',-100,100,0,0);
icontrast   :=sint('Contrast','Contrast|Adjust image contrast',-100,100,0,0);
ifeat       :=sint('Feather','Feather|Generate a feather|0 = Off| 1..200 = Feather edge pixels |-200..-1 = Feather all pixels',-200,200,0,0);
iqual       :=sint('Quality','Quality|Adjust image quality',1,100,100,100);//12mar2026
icolmix     :=sint('Color Mix','Color Mix|Adjust threshold point at which visible pixels mix from color 1 to color 2',1,255,1,1);

ialphaPower :=sint('Alpha Power','',0,500,100,100);//allow it to boost

end;

end;


//.main toolbar

with xhigh2 do
begin

ioptions:=ntitlebar(false,'','');

with ioptions do
begin
normal      :=true;
ounderline  :=false;
oflatback   :=true;
oheadalign  :=true;
oscaleh     :=scale_opts;

add('0',tepRotate20,0,'micon.rotate0','Rotate|No rotate');
add('90',tepRotate20,0,'micon.rotate90','Rotate|Rotate image right 90 degrees');
add('180',tepRotate20,0,'micon.rotate180','Rotate|Rotate image right 180 degrees');
add('270',tepRotate20,0,'micon.rotate270','Rotate|Rotate image right 270 degrees');

addsep;

add('Mirror',tepMirror20,0,'micon.mirror','Mirror|Flip image horizontally');
add('Flip',tepFlip20,0,'micon.flip','Flip|Flip image vertically');

addsep;

add('Remove Alpha',tepClose20,0,'micon.delalpha','Remove Alpha|Remove alpha channel values from source image before color processing');
add('Pre-Invert',tepInvert20,0,'micon.preinvert','Pre-Invert|Invert source image colors before color processing');
add('Enhance Range',tepColor20,0,'micon.range','Enhance Range|Spread source image colors over full color range before color processing');
add('Boost Detail',tepBW20,0,'micon.detail','Detail Boost|Use average RGB luminosity values during color processing for texture/detail boost');
add('Make Alpha',tepAsis20,0,'micon.alpha','Make Alpha|Artificially generate alpha values from luminosity levels during color processing');
add('Def Alpha',tepAsis20,0,'micon.defalpha','Default Alpha|Set final alpha value to 255');
add('Post-Invert',tepInvert20,0,'micon.invert','Invert|Invert image colors after color processing');

end;//options

end;



xhigh2.xgrad3;
imaintoolbar    :=xhigh2.xtoolbar2;
icaptureindex2  :=gui.rootwin.xhead.add('Capture',tepScreen20,0,'micon.capture',xhelpval('micon.capture'));

with gui.rootwin.xhead do
begin

add('Copy',tepCopy20,0,'micon.copy.png'       ,xhelpval('micon.copy.png'));
add('Paste',tepPaste20,0,'micon.paste'        ,xhelpval('micon.paste'));
add('Paste 2',tepPaste20,0,'micon.paste2'     ,xhelpval('micon.paste2'));

addsep;
add('PNG',tepCopy20,0,'micon.copy.array.png'  ,xhelpval('micon.copy.array.png'));
add('TEA',tepCopy20,0,'micon.copy.array.tea'  ,xhelpval('micon.copy.array.tea'));
add('ICO',tepCopy20,0,'micon.copy.array.ico'  ,xhelpval('micon.copy.array.ico'));
add('GIF',tepCopy20,0,'micon.copy.array.gif'  ,xhelpval('micon.copy.array.gif'));

addsep;
add('PNG',tepCopy20,0,'micon.copy.b64.png'    ,xhelpval('micon.copy.b64.png'));
add('ICO',tepCopy20,0,'micon.copy.b64.ico'    ,xhelpval('micon.copy.b64.ico'));
add('GIF',tepCopy20,0,'micon.copy.b64.gif'    ,xhelpval('micon.copy.b64.gif'));

end;

with imaintoolbar do
begin

normal:=false;
oheadalign:=true;
icaptureindex:=add('Capture',tepScreen20,0,'micon.capture',xhelpval('micon.capture'));
add('Open',tepOpen20,0,'micon.open.img','Open|Open source image from file');

add('Clear',tepClose20,0,'micon.clear'      ,'Clear|Clear image');
add('Copy',tepCopy20,0,'micon.copy.png'     ,xhelpval('micon.copy.png'));
add('Copy Source',tepCopy20,0,'micon.copy'  ,'Copy|Copy source image to Clipboard');
add('Paste',tepPaste20,0,'micon.paste'      ,xhelpval('micon.paste'));

addsep;
add('PNG',tepSave20,0,'micon.save.png','Save Image|Save image in PNG format to file');
add('TEA',tepSave20,0,'micon.save.tea','Save Image|Save image in TEA format to file');
add('ICO',tepSave20,0,'micon.save.ico','Save Image|Save image in ICO format to file');
add('GIF',tepSave20,0,'micon.save.gif','Save Image|Save image in GIF format to file.'+xhelpval('gif.restriction'));

addsep;
add('PNG',tepCopy20,0,'micon.copy.array.png'  ,xhelpval('micon.copy.array.png'));
add('TEA',tepCopy20,0,'micon.copy.array.tea'  ,xhelpval('micon.copy.array.tea'));
add('ICO',tepCopy20,0,'micon.copy.array.ico'  ,xhelpval('micon.copy.array.ico'));
add('GIF',tepCopy20,0,'micon.copy.array.gif'  ,xhelpval('micon.copy.array.gif'));

addsep;
add('PNG',tepCopy20,0,'micon.copy.b64.png'    ,xhelpval('micon.copy.b64.png'));
add('ICO',tepCopy20,0,'micon.copy.b64.ico'    ,xhelpval('micon.copy.b64.ico'));
add('GIF',tepCopy20,0,'micon.copy.b64.gif'    ,xhelpval('micon.copy.b64.gif'));

end;


//events
ocanshowmenu:=true;
showmenuFill1:=xonshowmenuFill1;
showmenuClick1:=xonshowmenuClick1;
iscreen.onpaint:=xscreen__onpaint;
icolormodes.onclick:=__onclick;
isettings.onclick:=__onclick;
ioptions.onclick:=__onclick;
imaintoolbar.onclick:=__onclick;
itabs.onclick:=__onclick;

imaintoolbar.onnotify:=_onnotify;
gui.rootwin.xhead.onnotify:=_onnotify;
iscreen.onnotify:=_onnotify;

//defaults
itabslot:=0;
xloadtab;
iloaded:=true;

//start
if xstart then start;
end;

destructor tmonoicon.destroy;
begin
try
//save open tab
xsavetab;

//controls
freeobj(@isource);
freeobj(@iimage);
freeobj(@irle6);
freeobj(@irle8);
freeobj(@irle32);
freeobj(@igrid);
str__free(@itabimg);
str__free(@itabset);

//self
inherited destroy;
except;end;
end;

function tmonoicon.getcapturing:boolean;
begin
result:=(icapturemode<>'');
end;

procedure tmonoicon.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tmonoicon.xcmd(sender:tobject;xcode:longint;xcode2:string);
begin
//init
if zzok(sender,7455) and (sender is tbasictoolbar) then
   begin
   //ours next
   //xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);
   cmd(xcode2);
   end;
end;

procedure tmonoicon.xupdatebuttons;
var
   p:longint;
   xcanpaste,xmustalign,bol1,bol2,bol3,bol4,bol5,bol6:boolean;
begin
try
//defaults
xmustalign :=false;
xcanpaste  :=canpaste;

//get
with itabs do
begin
benabled2['micon.pastetab']:=icanpastetab;

for p:=0 to (itablimit-1) do
begin
bmarked2['micon.tabslot.'+intstr32(p)]:=(itabslot=p);
btep2['micon.tabslot.'+intstr32(p)]:=tep__tick(itabslot=p);
end;
end;


with ioptions do
begin

bmarked2['micon.delalpha']   :=idelalpha;
bflash2['micon.delalpha']    :=idelalpha;

benabled2['micon.alpha']     :=canalpha;
bmarked2['micon.alpha']      :=ialpha;
bflash2['micon.alpha']       :=ialpha and canalpha;

benabled2['micon.defalpha']  :=not ialpha;
bmarked2['micon.defalpha']   :=idefalpha;
bflash2['micon.defalpha']    :=idefalpha and (not ialpha);

benabled2['micon.detail']    :=candetail;
bmarked2['micon.detail']     :=idetail;
bflash2['micon.detail']      :=idetail;

bmarked2['micon.range']      :=irange;
bflash2['micon.range']       :=irange;

bmarked2['micon.preinvert']  :=ipreinvert;
bflash2['micon.preinvert']   :=ipreinvert;

bmarked2['micon.invert']     :=iinvert;
bflash2['micon.invert']      :=iinvert;

bmarked2['micon.flip']       :=iflip;
bmarked2['micon.mirror']     :=imirror;

bmarked2['micon.rotate0']    :=(irotate=0);
bmarked2['micon.rotate90']   :=(irotate=90);
bmarked2['micon.rotate180']  :=(irotate=180);
bmarked2['micon.rotate270']  :=(irotate=270);
end;


with icolormodes do
begin

for p:=0 to ilmax do
begin

bmarked2['micon.mode.'+intstr32(p)]:=(imode=p);
btep2['micon.mode.'+intstr32(p)]   :=tep__tick(imode=p);

end;//p

end;


with isettings do
begin
btep2['micon.fastcapture']   :=tep__yes(ifastcapture);
btep2['micon.checker']       :=tep__yes(ishowchecker);
btep2['micon.frame']         :=tep__yes(ishowframe);
btep2['micon.framesm']       :=tep__yes(ishowframesm);
benabled2['micon.swapcols']  :=(mode=ilColor2);

if (bvisible2['micon.swapcols']<>(mode=ilColor2)) then
   begin

   bvisible2['micon.swapcols']  :=(mode=ilColor2);
   xmustalign                   :=true;

   end;

end;

//.colors
bol1                  :=icolor0.visible;
bol2                  :=icolor1.visible;
bol3                  :=icolor2.visible;
bol4                  :=icolmix.visible;
bol5                  :=ialphaPower.visible;

icolor0.visible       :=(mode=ilColor);
icolor1.visible       :=(mode=ilColor2);
icolor2.visible       :=(mode=ilColor2);
icolmix.enabled       :=(mode=ilColor2);
icolmix.visible       :=(mode=ilColor2);
ialphaPower.visible   :=ialpha;


if (bol1<>icolor0.visible) or (bol2<>icolor1.visible) or (bol3<>icolor2.visible) or (bol4<>icolmix.visible) or
   (bol5<>ialphaPower.visible)   then xmustalign:=true;


with imaintoolbar do
begin
bol1:=cansolid;
benabled2['micon.make.trans']:=bol1;
benabled2['micon.make.sold'] :=bol1;

bol1:=cansave;
benabled2['micon.save.png']  :=bol1;
benabled2['micon.save.ico']  :=bol1;
benabled2['micon.save.tea']  :=bol1;

benabled2['micon.paste']     :=xcanpaste;
benabled2['micon.resample']  :=canresample;
benabled2['micon.clear']     :=canclear;

bflash2['micon.capture']     :=capturing;
bpert2['micon.capture']      :=capturepert;
end;


with gui.rootwin.xhead do
begin

bflash2['micon.capture']     :=capturing;
bpert2['micon.capture']      :=capturepert;
benabled2['micon.paste']     :=xcanpaste;

end;


//align
if xmustalign then gui.fullalignpaint;

except;end;
end;

procedure tmonoicon.setmode(x:longint);
begin

imode:=frcrange32(x,0,ilmax);

end;

procedure tmonoicon.xcopybase64(xindex:longint;dformat:string);
label
   skipend;
var
   xresult:boolean;
   a:tbasicimage;
   d:tstr8;
   e:string;
begin

//defaults
xresult     :=false;
d           :=nil;
a           :=nil;
e           :=gecTaskfailed;

try

//check
if not cancopy then exit;

//init
a           :=misimg32(1,1);
d           :=str__new8;

//get
if strmatch(dformat,'gif') then
   begin

   if not xmakedata(xindex,fGIf,@d)   then goto skipend;

   end
else if strmatch(dformat,'ico') then
   begin

   if not xmakedata(xindex,fICO,@d)   then goto skipend;

   end
else
   begin

   dformat:='png';
   if not xmakedata(xindex,fPNG,@d) then goto skipend;

   end;

if not mis__fromdata(a,@d,e)                        then goto skipend;
if not clip__copyimageAsBase64(a,dformat,true)      then goto skipend;

//successful
xresult:=true;
skipend:
except;end;

//free
str__free(@d);
freeobj(@a);

//show error
if (not xresult) and (app__gui<>nil) then app__gui.poperror('',e);

end;

procedure tmonoicon.xcopypng(xindex:longint);
label
   skipend;
var
   xresult:boolean;
   a:tbasicimage;
   d:tstr8;
   e:string;
begin

//defaults
xresult :=false;
d       :=nil;
a       :=nil;
e       :=gecTaskfailed;

try
//check
if not cancopy then exit;

//get
d      :=str__new8;
a      :=misimg32(1,1);
if not xmakedata(xindex,fPNG,@d)           then goto skipend;
if not mis__fromdata(a,@d,e)               then goto skipend;
if not clip__copyimage(a)                  then goto skipend;

//successful
xresult:=true;
skipend:
except;end;

//free
str__free(@d);
freeobj(@a);

//show error
if (not xresult) and (app__gui<>nil) then app__gui.poperror('',e);

end;

procedure tmonoicon.xcopyarray(const xindex,ftype:longint);
label
   skipend;
var
   xresult:boolean;
   s,d:tstr8;
   e:string;
begin

//defaults
xresult     :=false;
s           :=nil;
d           :=nil;
e           :=gecTaskfailed;

try

//check
if not cancopy then exit;

//init
s     :=str__new8;
d     :=str__new8;

//get
if not xmakedata(xindex,ftype,@s) then goto skipend;

//copy
if not str__toarrayBYTE(@s,@d) then goto skipend;
if not clip__copytext2( @d )   then goto skipend;

//successful
xresult     :=true;
gui.popstatus(low__mbAUTO2(str__len32(@d),1,true)+' of text copied to Clipboard',1);

skipend:
except;end;

//free
str__free(@s);
str__free(@d);

//show error
if (not xresult) and (app__gui<>nil) then app__gui.poperror('',e);

end;

procedure tmonoicon.settabslot(x:longint);
begin
//save current tab
xsavetab;
//load new tab
itabslot:=frcrange32(x,0,itablimit-1);
xloadtab;
end;

function tmonoicon.xsettingschanged(xreset:boolean):boolean;
var
   x:string;
begin

x           :=bolstr(imirror)+bolstr(idelalpha)+bolstr(ialpha)+bolstr(idefalpha)+bolstr(idetail)+bolstr(irange)+bolstr(ipreinvert)+bolstr(iinvert)+bolstr(iflip)+'|'+insstr( intstr32(icliparea.left)+'_'+intstr32(icliparea.top)+'_'+intstr32(icliparea.right)+'_'+intstr32(icliparea.bottom), iclipactive<=0)+'|'+intstr32(irotate)+'|'+intstr32(icolor0.color)+'|'+intstr32(icolor1.color)+'|'+intstr32(icolor2.color)+'|'+intstr32(lcolor2(mode,true))+'|'+intstr32(lcolor(mode,true))+'|'+intstr32(iqual.val)+'|'+intstr32(icolmix.val)+'|'+intstr32(iscanTol.val)+'|'+intstr32(ibrightness.val)+'|'+intstr32(icontrast.val)+'|'+intstr32(ifeat.val)+'|'+intstr32(ialphaPower.val)+'|'+intstr32(imode)+'|'+intstr32(ipadw.val)+'|'+intstr32(ipadh.val)+'|'+intstr32(iminw.val)+'|'+intstr32(iminh.val)+'|'+intstr32(ishiftx.val)+'|'+intstr32(ishifty.val);
result      :=(x<>isettingsref);

if result and xreset then isettingsref:=x;

end;

procedure tmonoicon.xsavetab;
begin

xsavetab2(true,true);

end;

procedure tmonoicon.xsavetab2(ximage,xsettings:boolean);
var
   e:string;
   v:tvars8;
begin
//defaults
v:=nil;

try

//image
if ximage then mis__tofile(isource,xtabfile(itabslot,true),'png',e);

//settings
if xsettings then
   begin
   //init
   v:=tvars8.create;

   //get
   v.i['mode']      :=imode;
   v.i['minw']      :=iminw.val;
   v.i['minh']      :=iminh.val;
   v.i['shiftx']    :=ishiftx.val;
   v.i['shifty']    :=ishifty.val;
   v.i['padw']      :=ipadw.val;
   v.i['padh']      :=ipadh.val;
   v.i['capw']      :=icapw.val;
   v.i['caph']      :=icaph.val;
   v.i['tol']       :=iscanTol.val;
   v.i['tolcol']    :=icolmix.val;
   v.i['alphapower']:=ialphaPower.val;

   v.i['brightness']:=ibrightness.val;
   v.i['contrast']  :=icontrast.val;

   v.i['feather']   :=ifeat.val;
   v.i['quality']   :=iqual.val;
   v.b['checker']   :=ishowchecker;
   v.b['fastcapture']:=ifastcapture;
   v.b['frame']     :=ishowframe;
   v.b['framesm']   :=ishowframesm;
   v.i['color0']    :=icolor0.color;
   v.i['color1']    :=icolor1.color;
   v.i['color2']    :=icolor2.color;
   v.b['mirror']    :=imirror;
   v.b['flip']      :=iflip;
   v.b['preinvert'] :=ipreinvert;
   v.b['invert']    :=iinvert;
   v.b['detail']    :=idetail;
   v.b['delalpha']  :=idelalpha;
   v.b['alpha']     :=ialpha;
   v.b['defalpha']  :=idefalpha;
   v.b['range']     :=irange;
   v.i['rotate']    :=irotate;
   v.i['clip.l']    :=icliparea.left;
   v.i['clip.t']    :=icliparea.top;
   v.i['clip.r']    :=icliparea.right;
   v.i['clip.b']    :=icliparea.bottom;

   //set
   v.tofile(xtabfile(itabslot,false),e);

   //reset ref
   xsettingschanged(true);

   end;

except;end;
//free
freeobj(@v);
end;

function tmonoicon.xtabfile(const xindex:longint;const xpng:boolean):string;
begin

result:=xtabfile2(xindex,xpng,'');

end;

function tmonoicon.xtabfile2(const xindex:longint;const xpng:boolean;const xsubname:string):string;
begin

result:=app__settingsfile('tab'+intstr32(xindex)+insstr('-',xsubname<>'')+xsubname+'.'+low__aorbstr('ini','png',xpng));

end;

procedure tmonoicon.xloadtab;
var
   e:string;
   v:tvars8;
   int1:longint;
begin
//defaults
v:=nil;

try
//init
v:=tvars8.create;

//image
if not mis__fromfile(isource,xtabfile(itabslot,true),e) then
   begin

   missize(isource,32,32);
   mis__cls(isource,0,0,0,0);

   end;

//settings
v.fromfile(xtabfile(itabslot,false),e);

mode            :=v.idef('mode',1);//white
iminw.val       :=v.idef('minw',iminw.def);
iminh.val       :=v.idef('minh',iminh.def);
ishiftx.val     :=v.idef('shiftx',ishiftx.def);
ishifty.val     :=v.idef('shifty',ishifty.def);
ipadw.val       :=v.idef('padw',ipadw.def);
ipadh.val       :=v.idef('padh',ipadh.def);
icapw.val       :=v.idef('capw',icapw.def);
icaph.val       :=v.idef('caph',icaph.def);
iscanTol.val    :=v.idef('tol',iscanTol.def);
icolmix.val     :=v.idef('tolcol',icolmix.def);
ialphaPower.val :=v.idef('alphapower',ialphaPower.def);

ibrightness.val :=v.idef('brightness',ibrightness.def);
icontrast.val   :=v.idef('contrast',icontrast.def);

ifeat.val       :=v.idef('feather',ifeat.def);
iqual.val       :=v.idef('quality',iqual.def);

ifastcapture    :=v.bdef('fastcapture',false);//off
ishowchecker    :=v.bdef('checker',false);//off
ishowframe      :=v.bdef('frame',true);
ishowframesm    :=v.bdef('framesm',true);
icolor0.color   :=v.idef('color0',rgba0__int(255,128,0));
icolor1.color   :=v.idef('color1',rgba0__int(255,128,0));
icolor2.color   :=v.idef('color2',rgba0__int(0,128,255));
imirror         :=v.bdef('mirror',false);
iflip           :=v.bdef('flip',false);
ipreinvert      :=v.bdef('preinvert',false);
iinvert         :=v.bdef('invert',false);
irange          :=v.bdef('range',false);
idetail         :=v.bdef('detail',false);
idelalpha       :=v.bdef('delalpha',false);
ialpha          :=v.bdef('alpha',true);
idefalpha       :=v.bdef('defalpha',true);

//.rotate 0,90,180 and 270
int1          :=v.idef('rotate',0);
if (int1<>90) and (int1<>180) and (int1<>270) then int1:=0;
irotate       :=int1;

//.cliparea
icliparea.left    :=v.idef('clip.l',0);
icliparea.top     :=v.idef('clip.t',0);
icliparea.right   :=v.idef('clip.r',-1);
icliparea.bottom  :=v.idef('clip.b',-1);

//prime image
xmakeimage(iimage,imode,true);
xsyncRLE;

//reset ref
xsettingschanged(true);

//trigger paint
isourcechanged:=true;

except;end;

//free
freeobj(@v);

end;

procedure tmonoicon.xsyncRLE;
begin

irle6.slow__makefromLRGB( iimage );
irle8.slow__makefromLUM( iimage );
irle32.rgba__makefrom( iimage );

end;

procedure tmonoicon.xcopytab;
var
   e:string;
begin
xsavetab;
if not io__fromfile(xtabfile(itabslot,true),@itabimg,e) then str__clear(@itabimg);
if not io__fromfile(xtabfile(itabslot,false),@itabset,e)  then str__clear(@itabset);
icanpastetab:=true;
end;

procedure tmonoicon.xpastetab;
var
   e:string;
begin

if app__gui.popquery('Replace current work tab contents (image + settings) with internal Clipboard''s?') then
   begin

   io__tofile(xtabfile(itabslot,true),@itabimg,e);
   io__tofile(xtabfile(itabslot,false),@itabset,e);
   xloadtab;

   end;

end;

function tmonoicon.xlabelfilter(x:string):string;
begin
result:=strcopy1(x,1,50);
swapchars(result,';',':');//semi-colon reserved for separating multiple tab captions - 24oct2025
swapchars(result,#13,#32);
swapchars(result,#10,#32);
swapchars(result,#9,#32);
end;

procedure tmonoicon.xlabeltab;
var
   v:string;
begin

if (app__gui<>nil) then
   begin

   v:=icaplist[itabslot];
   if app__gui.popedit_small(v,'Type a caption for work tab #'+k64(1+itabslot),'') then
      begin
      icaplist[itabslot]:=xlabelfilter(v);
      xsynccaps;
      low__iroll(ichangedid,1);
      end;
   end;

end;

procedure tmonoicon.xsynccaps;
var
   p:longint;
begin

for p:=0 to pred(itablimit) do itabs.bcap2['micon.tabslot.'+intstr32(p)]:=k64(p+1)+'. '+strdefb(icaplist[p],'Tab');

end;

function tmonoicon.gettabinfo:string;
var
   p:longint;
begin

result:='';
for p:=0 to pred(itablimit) do result:=result+icaplist[p]+';';

end;

procedure tmonoicon.settabinfo(x:string);
var
   i,xlen,lp,p:longint;
begin

//init
x   :=x+';';
xlen:=low__len32(x);

//get
i :=0;
lp:=1;

for p:=1 to xlen do if (x[p-1+stroffset]=';') then
   begin

   icaplist[i]:=xlabelfilter( strcopy1(x,lp,p-lp) );

   //inc
   inc(i);
   lp:=p+1;

   //check
   if (i>=itablimit) then break;

   end;//p

//set
xsynccaps;

end;

procedure tmonoicon.setminw(x:longint);
begin
iminw.val:=x;
end;

procedure tmonoicon.setminh(x:longint);
begin
iminh.val:=x;
end;

function tmonoicon.getminw:longint;
begin
result:=iminw.val;
end;

function tmonoicon.getminh:longint;
begin
result:=iminh.val;
end;

procedure tmonoicon.setpadw(x:longint);
begin
ipadw.val:=x;
end;

procedure tmonoicon.setpadh(x:longint);
begin
ipadh.val:=x;
end;

function tmonoicon.getpadw:longint;
begin
result:=ipadw.val;
end;

function tmonoicon.getpadh:longint;
begin
result:=ipadh.val;
end;

//xxxxxxxxxxxxxxxxxxxxxxxxx//999999999999999999999999999999
function tmonoicon.xloadimg(s:tobject;sfilename:string):boolean;
label
   skipend;
var
   e:string;
   a:trawimage;
   sw,sh:longint;
begin
//defaults
result :=true;//pass-thru
a      :=nil;

//check
if not misok32(isource,sw,sh) then exit;

try

//init
a:=misraw32(1,1);

//s -> source
if misempty(a) and (sfilename<>'') then
   begin

   //from Clipboard - 10mar2026
   if strmatch('**paste**',sfilename) or strmatch('**paste2**',sfilename) then
      begin

      if clip__pasteimage(a,true) then
         begin

         misonecell(a);
         mis__copy(a,isource);
         xmakenow;

         if strmatch('**paste2**',sfilename) then clip__copyimageAsBase64(iimage,'png',true);

         end
      else goto skipend;

      end

   //from file
   else if mis__fromfile(a,sfilename,e) then
      begin

      misonecell(a);
      mis__copy(a,isource);

      end

   //no image
   else missize(a,1,1);

   end;

if misempty(a) then
   begin

   if not misempty(s) then
      begin

      mis__copy(s,isource);

      end
   else
      begin

      missize(isource,32,32);
      mis__cls(isource,0,0,0,0);

      end;

   end;

//max size
if (misw(isource)>isizelimit) or (mish(isource)>isizelimit) then
   begin

   missize(isource,frcmax32(misw(isource),isizelimit),frcmax32(mish(isource),isizelimit));

   end;

//save "source" to file
xsavetab2(true,false);

//set
isourcechanged:=true;

skipend:
except;end;

//free
freeobj(@a);

end;

procedure tmonoicon.xRGBAtoRGB(const d:tobject);//12mar2026
var
   s:tbasicimage;
   sx,sy,sw,sh:longint;
   sr32,dr32:pcolorrow32;
   s32,d32:pcolor32;

   procedure xmakeNonTransparent;
   const
      xmin  =4;
   begin

   if (d32.r<=xmin) then d32.r:=xmin+1;
   if (d32.g<=xmin) then d32.g:=xmin+1;
   if (d32.b<=xmin) then d32.b:=xmin+1;

   end;

begin

//defaults
s           :=nil;

//check
if not mask__hastransparency32(d) then exit;
if not misok32(d,sw,sh)           then exit;

//init
s           :=misimg32(sw,sh);

//d -> s
miscopy(d,s);

//s - size + cls
missize(d,sw+2,sh+2);
mis__cls(d,0,0,0,255);

//s -> d
for sy:=0 to pred(sh) do
begin

if not misscan32(s,sy,sr32  ) then exit;
if not misscan32(d,sy+1,dr32) then exit;

for sx:=0 to pred(sw) do
begin

s32         :=@sr32[sx+0];
d32         :=@dr32[sx+1];

case s32.a of
0:begin

   d32.r    :=0;
   d32.g    :=0;
   d32.b    :=0;

   end;

1..254:begin

   d32.r    :=(s32.r*s32.a) shr 8;
   d32.g    :=(s32.g*s32.a) shr 8;
   d32.b    :=(s32.b*s32.a) shr 8;

   xmakeNonTransparent;

   end;

255:begin

   d32.r    :=s32.r;
   d32.g    :=s32.g;
   d32.b    :=s32.b;

   xmakeNonTransparent;

   end;

end;//case

end;//dx

end;//dy

end;

function tmonoicon.lcolor(xindex:longint;xdemo:boolean):longint;
begin
case xindex of
ilblack   :result:=0;
ilwhite   :result:=rgba0__int(255,255,255);
ilBW      :result:=0;
ilcolor   :result:=icolor0.color;
ilcolor2  :result:=icolor1.color;
ilfont    :result:=low__aorb(0,vinormal.font,xdemo);
ilgrey    :result:=rgba0__int(255,255,255);
ilrgb     :result:=0;
else       result:=0;
end;//case
end;

function tmonoicon.lcolor2(xindex:longint;xdemo:boolean):longint;
begin
case xindex of
ilBW      :result:=rgba0__int(230,230,230);//rgba0__int(180,180,180);
ilcolor2  :result:=icolor2.color;
else       result:=0;
end;//case
end;

function tmonoicon.llabel(xindex:longint):string;
begin
case xindex of
ilblack   :result:='Black';
ilwhite   :result:='White';
ilBW      :result:='B/W';
ilcolor   :result:='1 Color';
ilcolor2  :result:='2 Color Mix';
ilfont    :result:='Font Color';//24oct2025
ilgrey    :result:='Grey';
ilrgb     :result:='RGB';
else       result:='Black';
end;//case
end;

function tmonoicon.lhelp(xindex:longint):string;//13mar2026, 31oct2025
begin
case xindex of
ilblack   :result:='Shades of black';
ilwhite   :result:='Shades of white';
ilBW      :result:='Shades of black and white';
ilcolor   :result:='Shades of custom color';
ilcolor2  :result:='Shades of two custom colors';
ilfont    :result:='Shades of app font color';
ilgrey    :result:='Shades of grey';
ilrgb     :result:='Color';
else       result:='Shades of black';
end;//case
end;

function tmonoicon.candetail:boolean;
begin

result:=true;

end;

function tmonoicon.canalpha:boolean;
begin

result:=true;

end;

function tmonoicon.xmakeimage(const d:tobject;const xindex:longint;const xdemo:boolean):boolean;
label
   skipend;

var
   sw,sh,ddw,ddh:longint32;

begin

//defaults
result      :=true;//pass-thru

//check
if not misok32(isource,sw,sh)        then exit;
if not misok32(d,ddw,ddh)            then exit;

try

//init
miscopy( isource ,d );


//get

//.cut image to specified area
img__clip( d ,icliparea );

//.delete alpha
if idelalpha then mask__setval( d ,255 );//make ALL pixels fully visible

//.make "top-left" pixel transparent OR use alpha channel if available
img__makeTransparent( d ,iscanTol.val );

//.cut unwanted outermost transparent area (left,right,top,bottom)
if (iscanTol.val>=2)         then img__crop( d );

//.automatically invert image for best output
case xindex of
ilRGB:;
else img__autoInvert( d );
end;//case

//.pre-invert
if ipreinvert then mis__invert32( d );

//.quality
//img__quality( d ,iqual.val );

//.stretch color/alpha luminosity to fill the full 0..255 8bit range
if irange then img__equalise( d ,255 );

//.apply effect
img__effect(d ,xindex ,icolmix.val ,ialphaPower.val ,lcolor(xindex,xdemo) ,lcolor2(xindex,xdemo) ,idetail ,ialpha ,idefAlpha );

//.manual invert
if iinvert then mis__invert32( d );

//.minWidthHeight
img__minWidthHeight( d ,iminw.val ,iminh.val );

//.insert transparent padding left/right and top/bottom
img__pad( d ,ipadw.val ,ipadh.val );

//.feather
img__feather( d ,ifeat.val );
img__feather( d ,ifeat.val );
img__feather( d ,ifeat.val );

//.shift image left/right and up/down
img__move( d ,ishiftx.val ,ishifty.val );

//.quality
img__quality( d ,iqual.val );


//finalise

mis__brightness_contrast32(d,ibrightness.val,icontrast.val,xindex);//12mar2026, 31oct2025
if imirror      then mis__mirror82432(d);
if iflip        then mis__flip82432(d);
if (irotate<>0) then mis__rotate82432(d,irotate);

skipend:
except;end;
end;

function tmonoicon.xmakedata(xindex,xformat:longint;xdata:pobject):boolean;
label
   skipend;
var
   e:string;
   d:tbasicimage;
begin
//defaults
result :=false;
e      :=gecTaskfailed;
d      :=nil;

try
//check
if not str__lock(xdata) then goto skipend;

//range
xformat:=frcrange32(xformat,0,fmax);

//init
str__clear(xdata);

//source -> d
d:=misimg32(1,1);
if not xmakeimage(d,xindex,false) then goto skipend;

//get - d -> data
case xformat of
fico:if not ico32__todata(d,xdata)                             then goto skipend;
ftea:if not tea__todata32(d,false,(xindex=ilfont),0,0,xdata,e) then goto skipend;
fgif:begin

   //GIF expects a simple mask of 0 or 255, all values of 1..254 are treated as solid -> so convert the mask
   //here into "0=>0" and "1..255=>255" - 18mar2026
   mask__forcesimple0255( d );

   //make GIF
   if not mis__todata(d,xdata,'gif',e)                         then goto skipend;

   end;
else if not mis__todata(d,xdata,'png',e)                       then goto skipend;
end;//case

//successful
result:=true;
skipend:
except;end;

//clear on error
if not result then str__clear(xdata);

//free
freeobj(@d);
str__uaf(xdata);

end;

procedure tmonoicon._ontimer(sender:tobject);
var
   xmustflash,xmustpaint:boolean;
begin
try

//defaults
xmustpaint  :=false;
xmustflash  :=false;

//capture
if (icapturemode<>'') then capture;

//timer500
if (ms64>=itimer500) then
   begin
   //update buttons
   xupdatebuttons;

   //flash
   iflashON:=not iflashON;
   xmustflash:=true;

   //reset
   itimer500:=ms64+500;
   end;

//timer100
if (ms64>=itimer100) or xmustpaint then
   begin

   //capture
   if strmatch(icapturemode,'move') and (ms64>icapturemoveref) then capturestop;

   //auto-make - 12mar2026
   xmakenow;

   //reset
   itimer100:=add64( ms64 ,low__aorb(100,10,app__turbook) );
   end;

//paint
if imustpaint then
   begin

   xmustpaint:=true;
   imustpaint:=false;

   end;
   
if      xmustpaint then paintnow
else if xmustflash then iscreen.paintnow;

except;end;
end;

procedure tmonoicon.xmakenow;//12mar2026
var
   b:tstr8;
begin

//detect changes
if iloaded and (xsettingschanged(true) or isourcechanged) then
   begin

   try

   //defaults
   b        :=nil;

   //reset
   isourcechanged:=false;

   //save tab
   xsavetab;

   //init
   xmakeimage(iimage,imode,true);
   xsyncRLE;
   b        :=str__new8;

   //get
   //.png
   xmakedata(mode,fPNG,@b);
   ibytesPNG:=str__len32(@b);

   //.gif
   xmakedata(mode,fGIF,@b);
   ibytesGIF:=str__len32(@b);

   //.ico
   xmakedata(mode,fICO,@b);
   ibytesICO:=str__len32(@b);

   //.tea
   xmakedata(mode,fTEA,@b);
   ibytesTEA:=str__len32(@b);

   //.colors
   icolors      :=miscountcolors(iimage);
   imaskshades  :=mask__count(iimage);

   except;end;

   //buttons
   xupdatebuttons;

   //paint
   imustpaint:=true;

   //turbo
   app__turbo;

   //free
   str__free(@b);

   end;

end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//11111111111111111111111111
procedure tmonoicon.clipcancel;
begin
iclipactive:=0;
icliparea:=nilarea;
isourcechanged:=true;
end;

procedure tmonoicon.capturestop;
begin
if (icapturemode<>'') then
   begin
   icapturemode:='';//off
   xupdatebuttons;
   gui.popstatus('Capture Complete',low__aorb(2,1,ifastcapture));
   end;
end;

function tmonoicon.capturepert:longint;
begin

if strmatch(icapturemode,'move') then
   begin

   result:=frcrange32(round32( sub64(icapturemoveref,ms64)/frcmin64(round64(0.01*xcapturetime),1) ),0,100);

   end
else result:=0;

end;

procedure tmonoicon.capture;
var
   a:twinbmp;
   b:tpoint;
   aw,ah:longint;
begin
//defaults
a:=nil;

try
//init
clipcancel;
icaptureref64:=add64(ms64,2000);
b:=low__getcursorposb;

//check
if low__setstr(icaptureref,intstr32(b.x)+'|'+intstr32(b.y)) then
   begin
   if strmatch(icapturemode,'move') then icapturemoveref:=add64(ms64,xcapturetime);
   end;

a:=twinbmp.create;
aw:=frcmin32(icapw.val,iminw.val);
ah:=frcmin32(icaph.val,iminh.val);
missize(a,aw,ah);

//get
low__cap2432c(b.x-(aw div 2),b.y-(ah div 2),aw,ah,a);

//set
xloadimg(a,'');
itimer100:=0;//update immediately
except;end;
//free
freeobj(@a);
end;

function tmonoicon.popsaveimg(xformat:longint;var xfilename:string;xcommonfolder,xtitle2:string):boolean;
var
   xfilterindex:longint;
   daction,xfilterlist:string;
begin
result:=false;

try
//range
xformat:=frcrange32(xformat,0,fmax);

//filterlist
xfilterindex:=0;
case xformat of
fico:xfilterlist:=peico;
ftea:xfilterlist:=petea;
fgif:xfilterlist:=pegif;
else xfilterlist:=pepng;
end;

//get
daction:='';
result:=gui.xpopnav3(xfilename,xfilterindex,xfilterlist,strdefb(xcommonfolder,low__platfolder('images')),'save','','Save Image'+xtitle2,daction,true);
except;end;
end;

procedure tmonoicon.xsaveas(xindex,xformat:longint);
label
   skipend;
var
   xresult:boolean;
   d:tstr8;
   e:string;
begin
//defaults
xresult :=false;
d       :=nil;
e       :=gecTaskfailed;

try
//range
xformat:=frcrange32(xformat,0,fmax);

//check
if not cansave then exit;

//get
ilastsavefile:=strdefb(ilastsavefile,ilastopenfile);
if popsaveimg(xformat,ilastsavefile,'','') then
   begin
   d:=str__new8;
   if not xmakedata(xindex,xformat,@d)      then goto skipend;
   if not io__tofile(ilastsavefile,@d,e) then goto skipend;
   end;

//successful
xresult:=true;
skipend:
except;end;
//free
str__free(@d);
//show error
if (not xresult) and (app__gui<>nil) then app__gui.poperror('',e);
end;

function tmonoicon.canclear:boolean;
begin
result:=true;
end;

function tmonoicon.cansolid:boolean;
begin
result:=true;
end;

function tmonoicon.cansave:boolean;
begin
result:=true;
end;

function tmonoicon.cancopy:boolean;
begin
result:=not misempty(isource);
end;

function tmonoicon.canpaste:boolean;
begin
result:=clip__canpasteimage(true);//18mar2026
end;

procedure tmonoicon.paste;
begin

if canpaste then
   begin

   icliparea          :=nilarea;
   xloadimg(nil,'**paste**');

   end;

end;

procedure tmonoicon.paste2;
begin

if canpaste then
   begin

   icliparea          :=nilarea;
   xloadimg(nil,'**paste2**');

   end;

end;

function tmonoicon.canresample:boolean;
begin
result:=true;
end;

procedure tmonoicon.xonshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin
try
//check
if zznil(xmenudata,5000) then exit;

//init
xmenuname:='main-app.'+xstyle;

//menu
if (xstyle='menu.image') then
   begin
   low__menuitem2(xmenudata,tepCopy20,'Copy','Copy image to Clipboard','micon.copy',100,aknone,cancopy);
   low__menuitem2(xmenudata,tepPaste20,'Paste','Paste image from Clipboard','micon.paste',100,aknone,canpaste);
   end;
except;end;
end;

function tmonoicon.xonshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
result:=true;
cmd(xcode2);
end;

function tmonoicon.cancmd(x:string):boolean;
begin
result:=strmatch(strcopy1(x,1,6),'micon.');
end;

procedure tmonoicon.cmd(x:string);
var
   int1,v32:longint;
   v:string;
   xmustpaint:boolean;

   function mv(const s:string):boolean;
   begin

   result:=strm(x,s,v,v32);

   end;

   function m(s:string):boolean;
   begin
   result:=strmatch(s,x);
   end;

begin
try

//defaults
xmustpaint            :=false;
v                     :='';
v32                   :=0;

//check
if cancmd(x) then x:=strcopy1(x,7,low__len32(x)) else exit;

//get
if m('resample') then
   begin

   xmustpaint         :=true;

   end
else if m('clear') then
   begin

   if gui.popquery('Clear tab contents?') then
      begin

      xclearimg;
      xsavetab2(true,false);

      end;

   end

else if m('copytab') then xcopytab

else if m('pastetab') then xpastetab

else if m('labeltab') then xlabeltab

else if m('open.img') then xopenimg

else if m('save.png') then xsaveas(mode,fPNG)

else if m('save.gif') then xsaveas(mode,fGIF)

else if m('save.ico') then xsaveas(mode,fICO)

else if m('save.tea') then xsaveas(mode,fTEA)

else if mv('copy.b64.') then xcopybase64(mode,v)

else if m('copy.png') then xcopypng(mode)

//copy as array in these formats - 10mar2026
else if m('copy.array.tea') then xcopyarray(mode,fTEA)
else if m('copy.array.png') then xcopyarray(mode,fPNG)
else if m('copy.array.gif') then xcopyarray(mode,fGIF)
else if m('copy.array.ico') then xcopyarray(mode,fICO)

else if m('copy') then
   begin

   if cancopy then clip__copyimage(isource);

   end

else if m('paste')      then paste
else if m('paste2')  then
   begin

   paste;
   xcopyarray(mode,fPNG);

   end
else if mv('mode.') then
   begin

   mode               :=v32;
   xupdatebuttons;
   xmustpaint         :=true;

   end
else if mv('tabslot.') then
   begin

   tabslot            :=v32;
   xupdatebuttons;
   xmustpaint         :=true;

   end
else if m('mirror') then
   begin

   imirror            :=not imirror;
   xupdatebuttons;

   end
else if m('flip') then
   begin

   iflip              :=not iflip;
   xupdatebuttons;

   end
else if m('preinvert') then
   begin

   ipreinvert         :=not ipreinvert;//13mar2026
   xupdatebuttons;

   end
else if m('invert') then
   begin

   iinvert            :=not iinvert;//11mar2026
   xupdatebuttons;

   end
else if m('range') then
   begin

   irange             :=not irange;
   xupdatebuttons;

   end
else if m('detail') then
   begin

   idetail            :=not idetail;
   xupdatebuttons;

   end
else if m('alpha') then
   begin

   ialpha             :=not ialpha;
   xupdatebuttons;

   end
else if m('defalpha') then
   begin

   idefalpha          :=not idefalpha;
   xupdatebuttons;

   end
else if m('delalpha') then
   begin

   idelalpha          :=not idelalpha;
   xupdatebuttons;

   end
else if m('rotate0') then
   begin

   irotate            :=0;
   xupdatebuttons;

   end
else if m('rotate90') then
   begin

   irotate            :=90;
   xupdatebuttons;

   end
else if m('rotate180') then
   begin

   irotate            :=180;
   xupdatebuttons;

   end
else if m('rotate270') then
   begin

   irotate            :=270;
   xupdatebuttons;

   end
else if m('fastcapture') then
   begin

   ifastcapture       :=not ifastcapture;
   xupdatebuttons;
   xmustpaint         :=true;

   end
else if m('checker') then
   begin

   ishowchecker       :=not ishowchecker;
   xupdatebuttons;
   xmustpaint         :=true;

   end
else if m('frame') then
   begin

   ishowframe         :=not ishowframe;
   xupdatebuttons;
   xmustpaint         :=true;

   end
else if m('framesm') then
   begin

   ishowframesm       :=not ishowframesm;
   xupdatebuttons;
   xmustpaint     :=true;

   end
else if m('swapcols') then
   begin

   int1               :=icolor2.color;
   icolor2.color      :=icolor1.color;
   icolor1.color      :=int1;
   xupdatebuttons;
   xmustpaint         :=true;

   end;

//paint
if xmustpaint then paintnow;

except;end;
end;

function tmonoicon._onnotify(sender:tobject):boolean;
var
   xmustpaint:boolean;
   int1,int2:longint;

   function xclickwithinEnlargedView:boolean;
   begin
   result:=(sender=iscreen) and area__within2(area__grow(iviewarea,20),iscreen.mousedownxy);//over allow slightly
   end;

begin
//defaults
result     :=false;
xmustpaint :=false;

try

if gui.mousedownstroke then
   begin

   if xclickwithinEnlargedView then
      begin

      if (iclipactive>=2) then
         begin
         iclipactive:=frcmin32(iclipactive-1,0);
         iclipdownxy:=iscreen.mousedownxy;
         iclipmovexy:=iclipdownxy;
         xmustpaint:=true;
         end;

      if (iclipactive<=0) then
         begin
         iclipdownxy:=iscreen.mousedownxy;
         iclipmovexy:=iclipdownxy;
         iclipactive:=3;
         xmustpaint:=true;
         end;

      end;

   //captuure -> can/detect
   icancapture:=(imaintoolbar.focused and (imaintoolbar.downindex=icaptureindex)) or (gui.rootwin.xhead.focused and (gui.rootwin.xhead.downindex=icaptureindex2));

   end;

if gui.mousemoved then
   begin

   //help
   if (sender=iscreen) then
      begin

      case  area__within2(area__grow(iviewarea,20),iscreen.mousemovexy) of
      true:iscreen.help:='Adjust Capture Area|Click and drag inside the Enlarged View display to adjust final capture area';
      else iscreen.help:='';
      end;//case

      end;
      
   //capture
   if icancapture and gui.mousedragging then
      begin
      icapturemode:='drag';
      icapturemoveref:=0;
      end;

   //clip
   if xclickwithinEnlargedView and (iclipactive<=1) then
      begin

      int1:=iscreen.mousemovexy.x;
      int2:=iscreen.mousemovexy.y;

      if (int1<>iclipmovexy.x) or (int2<>iclipmovexy.y) then
         begin

         iclipmovexy.x:=int1;
         iclipmovexy.y:=int2;
         xmustpaint:=true;

         end;

      end;
   end;

if gui.mouseupstroke then
   begin

   //clip.finish
   if (iclipactive>=1) then//16may2025
      begin
      iclipactive:=frcmin32(iclipactive-1,0);
      isourcechanged:=true;
      xmustpaint:=true;
      end;

   //capture -> off/move
   if strmatch(icapturemode,'drag') then capturestop
   else if (icapturemode='') and icancapture and (not gui.mousedragging) then
      begin
      icapturemode:='move';
      icapturemoveref:=add64(ms64,xcapturetime);
      end;

   //.off
   icancapture:=false;

   end;

//paint
if xmustpaint then paintnow;

except;end;
end;

function tmonoicon.xcapturetime:comp;
begin

case ifastcapture of
true:result:=750;
else result:=2000;
end;//case

end;

procedure tmonoicon.xopenimg;
begin
if gui.popopenimg(ilastopenfile,ilastopenfilter,'') then
   begin
   xloadimg(nil,ilastopenfile);
   xsavetab2(true,false);
   end;
end;

procedure tmonoicon.xclearimg;
begin
icliparea:=nilarea;
missize(isource,16,20);
mis__cls(isource,0,0,0,0);
isourcechanged:=true;
end;

function tmonoicon._onaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
begin
result:=true;

try
if io__fileexists(xfilename) then
   begin
   xloadimg(nil,xfilename);
   xsavetab2(true,false);
   paintnow;
   end;
except;end;
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxx//1111111111111111111111111
procedure tmonoicon.xscreen__onpaint(sender:tobject);//._onpaint()
const
   xlinespacing=1.2;
   vRLE6       =10;
   vRLE8       =11;
   vRLE32      =12;

var
   a:tclientinfo;
   xframe,xframesm:boolean;
   denlargedview,ca,da:twinrect;
   ai:tobject;
   vtmp,dcolw,dtextrightmostx,vsep,dright,dbottom,alargest,aw,ah,int1,int2,v,ox,oy,p,hpad,vpad,dx,dy,dy0:longint;
   xtab,str1:string;
   xtmp:tstr8;

   function xs(const xcount:longint):string;
   begin
   if (xcount<>1) then result:='s' else result:='';
   end;

   procedure xdrawtext(var dx,dy:longint;const dtab,x:string);
   begin

   if (x<>'') then
      begin

      iscreen.ftext(clnone,a.ci,dx,dy,a.font,dtab,x,a.fn,true);
      dtextrightmostx:=largest32( dtextrightmostx, dx + font__textwidth( dtab, x ,a.fn ) );

      end;

   inc(dy, trunc(a.fnH*xlinespacing) );

   end;

   procedure xdraw(d:tobject;const xindex:longint;var dx,dy,dwidth:longint;const denlargedview:boolean;xzoomfactor:longint;xcap:string;xbackcolor:longint);//07nov2025
   var
      x1,x2,y1,y2,dbits,ddw,ddh,dw,dh,int1,tx,ty,v:longint;
   begin

   //defaults
   dwidth   :=0;

   //check
   if not misok82432(d,dbits,dw,dh) then exit;

   //range
   xzoomfactor      :=frcrange32(xzoomfactor,1,izoomlimit);

   //init
   ddw              :=dw*a.zoom*xzoomfactor;
   ddh              :=dh*a.zoom*xzoomfactor;

   //calc
   tx:=dx;
   ty:=dy;
   inc(dy,a.fnH);
   inc(dy,vsep);

   da:=area__make(dx,dy,dx+ddw-1,dy+ddh-1);
   if denlargedview then iviewarea:=da;

   //cls
   if (xbackcolor<>clnone) then iscreen.ffillarea(area__grow(da,1),xbackcolor,false);

   //frame
   if (xframe and (xzoomfactor>1)) or (xframesm and (xzoomfactor<=1)) then
      begin

      int1  :=1;
      v     :=int__splice24(0.5,a.font,a.back);
      iscreen.foutlinearea(area__grow(da,1),v,false);

      end
   else int1:=0;

   //iscreen.ldbEXCLUDE(true,area__grow(da,int1),false);

   //title
   if (xcap<>'') then iscreen.ftext(clnone,a.ci,tx,ty,a.font,'',xcap,a.fn,true);

   //checkerboard image
   v:=insint(igridsize,iflashON);

   if (xbackcolor=clnone) then iscreen.fdraw3(igrid,area__make(0,v,ddw-1,v+ddh-1),da.left,da.top,ddw,ddh,clnone,255,0,false,false,true);

   //user image
   case xindex of
   vRLE6  :iscreen.fdraw2(irle6 ,da.left,da.top,a.font,a.line,clRed,clLime,255,true);
   vRLE8  :iscreen.fdraw2(irle8 ,da.left,da.top,a.font,a.line,clRed,clLime,255,true);
   vRLE32 :iscreen.fdraw (irle32,da.left,da.top,a.font,255,true);
   else    iscreen.fdraw3(d,misarea(d),da.left,da.top,ddw,ddh,clnone,255,0,false,false,true);
   end;

   //show cliparea during clip task
   if denlargedview and (iclipactive=1) then
      begin

      //get
      x1:=(frcrange32(iclipdownxy.x,da.left,da.right+1)-da.left) div xzoomfactor;
      x2:=(frcrange32(iclipmovexy.x,da.left,da.right+1)-da.left) div xzoomfactor;

      y1:=(frcrange32(iclipdownxy.y,da.top,da.bottom+1)-da.top) div xzoomfactor;
      y2:=(frcrange32(iclipmovexy.y,da.top,da.bottom+1)-da.top) div xzoomfactor;

      icliparea.left     :=smallest32(x1,x2);//x,y -> x+w,y+h
      icliparea.right    :=largest32(x1,x2);
      icliparea.top      :=smallest32(y1,y2);
      icliparea.bottom   :=largest32(y1,y2);

      ca.left    :=da.left + icliparea.left*xzoomfactor;
      ca.right   :=da.left + icliparea.right*xzoomfactor;
      ca.top     :=da.top + icliparea.top*xzoomfactor;
      ca.bottom  :=da.top + icliparea.bottom*xzoomfactor;

      //draw -> W/B/W -> visible against all colors
      iscreen.foutlinearea(ca,clwhite,false);
      iscreen.foutlinearea(area__grow(ca,1),clblack,false);
      iscreen.foutlinearea(area__grow(ca,2),clwhite,false);

      end;


   inc(dy,ddh);
   inc(dy,vsep);

   //bottom space
   inc(dy,2*vsep);

   if (xcap<>'') then v:=font__textwidth('',xcap,a.fn) else v:=0;
   da.right:=largest32(da.right,da.left+v);

   //drightboundary
   dwidth:=da.right-dx+1;

   end;

   function xcolorinfo(xindex:longint;var xlabel:string;var xcolor:longint):boolean;

      procedure s(n:string;v:longint);
      begin

      xlabel:=n;
      xcolor:=v;

      end;

   begin
   result:=true;

   case xindex of

   0     :s('Checker',clnone);
   1     :s('Window Client',a.back);
   2     :s('Window Head',viTitle.mback);
   3     :s('Black',0);
   4     :s('Grey',rgba0__int(128,128,128));
   5     :s('White',rgba0__int(255,255,255));
   6     :s('Red',rgba0__int(255,0,0));
   7     :s('Yellow',rgba0__int(255,255,0));
   8     :s('Blue',rgba0__int(0,0,255));
   9     :s('Green',rgba0__int(0,255,0));
   vRLE6 :s('RLE 6 (4 ch)',a.back);
   vRLE8 :s('RLE 8 (1 ch)',a.back);
   vRLE32:s('RLE 32',a.back);
   else result:=false;

   end;//case

   end;
begin
try
//defaults
xtmp:=nil;

//init
iscreen.infovars(a);
hpad        :=20*a.zoom;
vpad        :=20*a.zoom;
dx          :=a.ci.left+round(1*hpad);
dy0         :=a.ci.top + round(2.5*vpad);
dy          :=dy0;
ox          :=dx;
oy          :=dy;
da          :=area__make(ox,oy,ox,oy);
if (iclipactive>=1) then ai:=isource else ai:=iimage;
aw          :=misw(ai);
ah          :=mish(ai);
alargest    :=frcmin32( largest32(aw,ah) ,1 );
xframe      :=ishowframe;
xframesm    :=ishowframesm;
vsep        :=3*a.zoom;

//cls
iscreen.ffillArea(a.cs,a.back,false);

//enlarged view

//.dynamic zoom
case alargest of
min32..128:vtmp:=450;
else       vtmp:=frcmin32( alargest * 2 ,450 );//for larger images (128px +) adapt viewer size - 15apr2026
end;//case

v                    :=frcrange32( vtmp div alargest ,1 ,izoomlimit );

//.draw enalarged view
xdraw(ai,0,dx,dy,int2,true,v,'Enlarged View - '+low__aorbstr(llabel(mode)+' at '+k64(v*100)+'%','Adjust Capture Area',iclipactive>=1),low__aorb(a.back,clnone,ishowchecker));
denlargedview        :=da;


//details
dy                   :=denlargedview.bottom;
dx                   :=denlargedview.left;
dtextrightmostx      :=denlargedview.left;

inc(dy,round(1.5*a.fnH) );
xdrawtext(dx,dy,tbNone,'Image Details');
inc(dy,5*a.zoom);

xtab  :='L70;L70;R80;R100;';

xdrawtext(dx,dy,xtab,'PNG'+#9+'32 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesPNG)+' b');
xdrawtext(dx,dy,xtab,'TEA'+#9+'32 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesTEA)+' b');
xdrawtext(dx,dy,xtab,'ICO'+#9+'32 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesICO)+' b');
xdrawtext(dx,dy,xtab,'GIF'+#9+' 8 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesGIF)+' b');

xtab  :='L70;L200;';
xdrawtext(dx,dy,xtab,'Depth'+#9+k64(icolors)+' color'+xs(icolors)+' and '+k64(imaskshades)+' mask value'+xs(imaskshades));


//.draw actual views (1:1) - 31oct2025, 24oct2025

case (dtextrightmostx>=(denlargedview.right+64)) of
true:begin

   dbottom :=denlargedview.bottom;
   dright  :=denlargedview.right + hpad;

   end;
else begin

   dbottom :=a.cs.bottom;
   dright  :=frcmin32(dtextrightmostx, denlargedview.right) + hpad;

   end;
end;//case

dy         :=oy;
dx         :=dright;
xdrawtext(dx,dy,'','Actual Views on Sample Backgrounds');
inc(dy, (5*a.zoom) );
oy         :=dy;
dcolw      :=0;

for p:=0 to max32 do
begin

if not xcolorinfo(p,str1,int1) then break
else
   begin

   //new column
   if ((dy+ah+2+a.fnH+(4*vsep))>=dbottom) then
      begin

      inc(dx, dcolw + hpad );
      dy     :=oy;
      dcolw  :=0;

      end;

   //draw image preview
   xdraw(iimage,p,dx,dy,int2,false,1,str1,int1);

   //track dynamic column width -> text.width and image.width(int2)
   dcolw:=largest32( dcolw, largest32( font__textwidth('',str1,a.fn), int2 ) );

   end;

end;//p

except;end;

//free
freeobj(@xtmp);

end;


//## tapp ######################################################################
constructor tapp.create;
begin


if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));
ibuildingcontrol      :=true;
iloaded               :=false;
isettingsref          :='';
icouldcapture         :=false;


//need checkers
need_jpeg;
need_gif;
need_ico;

//init
itimer500             :=ms64;


//controls
with rootwin do
begin

static                :=true;
xhead;
xgrad;
//xgrad3;
//xstatus2.celltext[0]  :=app__info('des');
//xstatus2.cellalign[0] :=0;

icore                 :=tmonoicon.create(client);

end;//rootwin


with rootwin do
begin

xhead.xaddoptions;
xhead.xaddhelp;

end;


//default page to show
rootwin.xhead.parentpage        :='overview';

//events
rootwin.xhead.onclick           :=__onclick;
rootwin.xhead.showmenuFill1     :=xshowmenuFill1;
rootwin.xhead.showmenuClick1    :=xshowmenuClick1;
rootwin.xhead.ocanshowmenu      :=true;//use toolbar for special menu display - 18dec2021
rootwin.onaccept                :=icore._onaccept;//drag and drop support

//start timer event
ibuildingcontrol                :=false;
xloadsettings;

//finish
createfinish;

end;

destructor tapp.destroy;
begin
try

//settings
xautosavesettings;

//self
inherited destroy;

except;end;
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;

var
   e:string;

   function m(x:string):boolean;
   begin

   result:=strmatch(x,xcode2);

   end;

begin//use for testing purposes only - 15mar2020
try

//defaults
e           :='';

//init
if zzok(sender,7455) and (sender is tbasictoolbar) then
   begin

   //ours next
   //xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);

   end;

//get
if icore.cancmd(xcode2) then icore.cmd(xcode2);

//successful
skipend:
except;end;

if (e<>'') then gui.popstatus(e,2);

end;


procedure tapp.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin
try
//check
if zznil(xmenudata,5000) then exit;

except;end;
end;

function tapp.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
result:=true;xcmd(nil,0,xcode2);
end;

procedure tapp.xloadsettings;
var
   a:tvars8;
begin
try

//defaults
a:=nil;

//check
if zznil(prgsettings,5001) then exit;

//init
a:=vnew2(950);

//filter
a.i['tab']            :=prgsettings.idef('tab',0);
a.s['tab.info']       :=prgsettings.sdef('tab.info','');

//sync
prgsettings.data:=a.data;

//set
icore.tabslot        :=a.i['tab'];
icore.tabinfo        :=a.s['tab.info'];

except;end;

//free
freeobj(@a);
iloaded:=true;

end;

procedure tapp.xsavesettings;
var
   a:tvars8;
begin
try
//check
if not iloaded then exit;

//defaults
a:=nil;
a:=vnew2(951);

//get
a.i['tab']        :=icore.tabslot;
a.s['tab.info']   :=icore.tabinfo;

//set
prgsettings.data:=a.data;
siSaveprgsettings;
except;end;
//free
freeobj(@a);
end;

procedure tapp.xautosavesettings;
begin
if iloaded and low__setstr(isettingsref,intstr32(icore.tabslot)+'|'+intstr32(icore.changedid)) then xsavesettings;
end;

procedure tapp.__onclick(sender:tobject);
begin
try;xcmd(sender,0,'');except;end;
end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
begin
try
//check
if not iloaded then exit;


//timer500
if (ms64>=itimer500) then
   begin

   //savesettings
   xautosavesettings;

   //reset
   itimer500:=ms64+500;
   end;

//debug tests
//if system_debug then debug_tests;
except;end;
end;

function mis__brightness_contrast32(s:tobject;xbrightness100,xcontrast100,xindex:longint):boolean;//09nov2025
label
   skipend;
var
   sw,sh,sx,sy:longint;
   sr32 :pcolorrow32;
   c32  :tcolor32;

   procedure dbrightness(var dv:byte);
   var
      v:longint;
   begin

   v  :=dv + xbrightness100;
   if (v<0) then v:=0 else if (v>255) then v:=255;
   dv :=byte(v);

   end;

   procedure dcontrast(var dv:byte);
   var
      v,v2:longint;
   begin

   if (xcontrast100<0) then v2:=255 else v2:=256-xcontrast100;//adjust the multipler scale as we increase the contrast value

   v  :=dv + ((dv-127)*xcontrast100) div v2;
   if (v<0) then v:=0 else if (v>255) then v:=255;
   dv :=byte(v);

   end;

begin

//defaults
result :=false;

//check
if not misok32(s,sw,sh) then exit;

try
//range
xbrightness100 :=frcrange32(xbrightness100,-100,100);
xcontrast100   :=frcrange32(xcontrast100,-100,100);
xindex         :=frcrange32(xindex,0,ilmax);

//.nothing to do -> skip
if (xbrightness100=0) and (xcontrast100=0) then
   begin

   result:=true;
   goto skipend;

   end;

//get
for sy:=0 to (sh-1) do
begin

if not misscan32(s,sy,sr32) then goto skipend;

for sx:=0 to (sw-1) do
begin

//get
c32:=sr32[sx];

//brightness
if (xbrightness100<>0) then
   begin

   if (xindex=ilfont) then
      begin

      //mask only for "font color"
      if (c32.a>=1) then dbrightness(c32.a)

      end
   else
      begin

      dbrightness(c32.r);
      dbrightness(c32.g);
      dbrightness(c32.b);

      end;

   end;

//contrast
if (xcontrast100<>0) then
   begin

   if (xindex=ilfont) then
      begin

      //mask only for "font color"
      if (c32.a>=1) then dcontrast(c32.a)

      end
   else
      begin

      dcontrast(c32.r);
      dcontrast(c32.g);
      dcontrast(c32.b);

      end;

   end;

//set
sr32[sx]:=c32;

end;//sx

end;//sy

//successful
result:=true;
skipend:

except;end;
end;

function mis__invert32(s:tobject):boolean;//11mar2026
label
   skipend;
var
   sw,sh,sx,sy:longint;
   sr32 :pcolorrow32;
   s32  :pcolor32;

begin

//defaults
result :=false;

//check
if not misok32(s,sw,sh) then exit;

try

//get
for sy:=0 to (sh-1) do
begin

if not misscan32(s,sy,sr32) then goto skipend;

for sx:=0 to (sw-1) do
begin

//get
s32         :=@sr32[sx];
s32.r       :=255-s32.r;
s32.g       :=255-s32.g;
s32.b       :=255-s32.b;

end;//sx

end;//sy

//successful
result:=true;
skipend:

except;end;
end;

end.
