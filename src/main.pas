unit main;

interface
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define jpeg} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gossio, gossimg, gossnet;
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2025 Blaiz Enterprises ( http://www.blaizenterprises.com )
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
//## Version.................. 1.00.1632 (+15)
//## Items.................... 2
//## Last Updated ............ 09nov2025, 07nov2025, 31oct2025, 24oct2025, 05jun2025, 03jun2025, 01jun2025, 24may2025
//## Lines of Code............ 3,300+
//##
//## main.pas ................ app code
//## gossroot.pas ............ console/gui app startup and control
//## gossio.pas .............. file io
//## gossimg.pas ............. image/graphics
//## gossnet.pas ............. network
//## gosswin.pas ............. 32bit windows api's/xbox controller
//## gosssnd.pas ............. sound/audio/midi/chimes
//## gossgui.pas ............. gui management/controls
//## gossdat.pas ............. app icons (32px and 20px), splash image (208px), help documents (gui only) in txt, bwd or bwp format
//## gosszip.pas ............. zip support
//## gossjpg.pas ............. jpeg support
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tapp                   | tbasicapp         | 1.00.070  | 24oct2025   | App - 01jun2025, 16may2025, 12may2025
//## | tmonoicon              | tbasiccontrol     | 1.00.1547 | 07nov2025   | Pixel snatcher and tool-icon editor - 31oct2025, 24oct2025, 05jun2025, 03jun2025, 01jun2025, 16may2025, 12may2025, 06may2025
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
   ilrgba     =6;
   ilrgba2    =7;//24may2025
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
    isource,isource2:trawimage;
    igrid,iimage:tbasicimage;
    ichangedid,itabslot,itabcount,icaptureindex2,icaptureindex,imode:longint;
    iscreen:tbasiccontrol;
    itabs,imaintoolbar,icolormodes,isettings,ioptions:tbasictoolbar;
    icolor0,icolor1,icolor2:tbasiccolor;
    //.other
    irotate,iclipactive,izoomlimit,isizelimit,imaskshades,icolors,iquality,ibytesPNG,ibytesGIF,ibytesICO,ibytesTEA,igridsize,ilastopenfilter:longint;
    iflip,imirror,icanpastetab,iloaded,icancapture,ishowframe,ishowframesm,ifastcapture,ishowchecker,isourcechanged,idatachanged:boolean;
    icapturemode,icaptureref,isettingsref,ilastopenfile,ilastsavefile:string;
    iflashON:boolean;
    ipadw,ipadh,iminw,iminh,icapw,icaph,iopac,ifeat,itol,itolCol,iqual,ibrightness,icontrast,ishiftx,ishifty:tsimpleint;
    icaplist:array[0..(itablimit-1)] of string;

    procedure xopenimg;
    function xloadimg(s:tobject;sfilename:string):boolean;
    procedure xclearimg;
    function xmakeimage(d:tobject;xindex:longint;xdemo:boolean):boolean;
    function xmakeimage2(d:tobject;xindex,dshiftx,dshifty,dtolCol,dtol,dfeather,dopacity,wautopad,hautopad,dquality,dbrightness100,dcontrast100,dw,dh:longint;xdemo:boolean):boolean;
    function xmakedata(xindex,xformat:longint;xdata:pobject):boolean;
    procedure xcopybase64(xindex:longint;dext:string);
    procedure xcopytea(xindex:longint);
    procedure xcopypng(xindex:longint);
    function popsaveimg(xformat:longint;var xfilename:string;xcommonfolder,xtitle2:string):boolean;
    procedure xsaveas(xindex,xformat:longint);
    procedure xonshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xonshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    procedure setquality(x:longint);
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
    function xtabfile(xindex:longint;xpng:boolean):string;
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

   public

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean); override;
    destructor destroy; override;
    function _onnotify(sender:tobject):boolean; override;
    function _onaccept(sender:tobject;xfolder,xfilename:string;xindex,xcount:longint):boolean;
    procedure _ontimer(sender:tobject); override;

    //information
    property mode:longint read imode write setmode;
    property tabslot:longint read itabslot write settabslot;
    property quality:longint read iquality write setquality;
    property minw:longint read getminw write setminw;
    property minh:longint read getminh write setminh;
    property padw:longint read getpadw write setpadw;
    property padh:longint read getpadh write setpadh;
    property showchecker:boolean read ishowchecker write ishowchecker;
    property fastcapture:boolean read ifastcapture write ifastcapture;
    property capturing:boolean read getcapturing;
    property changedid:longint read ichangedid;
    property tabinfo:string read gettabinfo write settabinfo;
    //command
    function cancmd(x:string):boolean;
    procedure cmd(x:string);
    //can
    function cansolid:boolean;
    function cancopy:boolean;
    function canpaste:boolean;
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
function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;
function app__syncandsavesettings:boolean;

function mis__brightness_contrast32(s:tobject;xbrightness100,xcontrast100,xindex:longint):boolean;//09nov2025


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
else if (xname='height')              then result:='880'
else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='ver')                 then result:='1.00.1632'
else if (xname='date')                then result:='09nov2025'
else if (xname='name')                then result:='Pixel Snatcher'
else if (xname='web.name')            then result:='pixelsnatcher'//used for website name
else if (xname='des')                 then result:='Snatch screen pixels and convert into translucent tool images in PNG, GIF, ICO and TEA image formats with ease'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')
else if (xname='new.instance')        then result:='1'//1=allow new instance, else=only one instance of app permitted
else if (xname='screensizelimit%')    then result:='95'//95% of screen area
else if (xname='realtimehelp')        then result:='0'//1=show realtime help, 0=don't
else if (xname='hint')                then result:='1'//1=show hints, 0=don't

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'
//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)
//.software
else if (xname='software.tep')        then result:=intstr32(low__aorb(tepNext20,tepIcon20,sizeof(program_icon20h)>=2))
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

function app__findcustomtep(xindex:longint;var xdata:tlistptr):boolean;

  procedure m(const x:array of byte);//map array to pointer record
  begin
  {$ifdef gui}
  xdata:=low__maplist(x);
  {$else}
  xdata.count:=0;
  xdata.bytes:=nil;
  {$endif}
  end;
begin//Provide the program with a set of optional custom "tep" images, supports images in the TEA format (binary text image)
//defaults
result:=false;

//sample custom image support

//m(tep_none);
{
case xindex of
5000:m(tep_write32);
5001:m(tep_search32);
end;
}

//successful
//result:=(xdata.count>=1);
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


//## tmicon ####################################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//1111111111111111111111111
constructor tmonoicon.create2(xparent:tobject;xscroll,xstart:boolean);
const
   vsep         =7;
   vlabelratio  =0;
   vcontrolratio=0.4;//.6;
   scale_tabs=0.92;
   scale_opts=0.73;
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

   function xint(xcap,xhelp:string;xmin,xmax,xdef,xval:longint):tbasicint;
   begin
   result:=icurrentsubcol.nint(xcap,xhelp,xmin,xmax,xdef,xval);
   result.oflatback:=true;
   if not xfirst then result.osepv:=round(vcontrolratio*vsep);
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

   if      (x='micon.copy.tea')      then result:='Copy Image|Copy image to Clipboard as a Pascal array in 32 bit TEA format. Image data can be directly included into any Gossamer app source code.'
   else if (x='micon.copy.b64.png')  then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format PNG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
   else if (x='micon.copy.b64.gif')  then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format GIF. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'+xhelpval('gif.restriction')
   else if (x='micon.capture')       then result:='Capture image from screen|Hold down this button and drag to capture screen in realtime without delay, alternatively, click this button and hover '+'your cursor at the capture location, holding it still for capture to automatically complete after a short delay'
   else if (x='gif.restriction')     then result:='|*|'+'Format Restriction|The GIF image format can only store 2 mask values (on and off) and 256 colors. An image with subtle mask values, or 2 or more, or more than 256 colors may appear incorrectly.'
   else if (x='micon.copy.png')      then result:='Copy|Copy image to Clipboard'
   else if (x='micon.paste')         then result:='Paste|Paste image from Clipboard'

   else
      begin
      result:='';
      showbasic('Undefined help.val');
      end;

   end;

begin
//self
inherited create2(xparent,xscroll,false);

//var
iloaded          :=false;
bordersize       :=0;
oautoheight      :=true;
itimer500        :=0;
itimer100        :=0;
ilastopenfile    :='';
ilastopenfilter  :=0;
ilastsavefile    :='';
iflashON         :=false;
izoomlimit       :=15;
isizelimit       :=128;
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
irotate          :=0;

//images
isource      :=misraw32(1,1);//resizable
isource2     :=misraw32(1,1);//resizable
iimage       :=misimg32(1,1);

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
with xnewcol(1,120,false).client do
begin
iscreen:=ncontrol;
iscreen.oautoheight:=true;
iscreen.bordersize:=10;
end;


//.color modes etc
with xnewcol(2,25,true).client do
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
oscaleh   :=scale_opts;
oscalevpad:=scale_vpad;

for p:=0 to ilmax do
   begin
   add(llabel(p),tepYesBlank20,0,'micon.mode.'+intstr32(p),'Color Mode|'+lhelp(p));
   newline;
   end;
end;//color modes

xlabel('Options','');
ioptions:=ntoolbar('');

with ioptions do
begin
normal:=true;
ounderline :=false;
oflatback  :=true;
oheadalign:=false;
halign:=0;
oscaleh   :=scale_opts;
oscalevpad:=scale_vpad;

add('Mirror',tepMirror20,0,'micon.mirror','Mirror|Flip image horizontally');
newline;

add('Flip',tepFlip20,0,'micon.flip','Flip|Flip image vertically');
newline;


add('0',tepRotate20,0,'micon.rotate0','Rotate|No rotate');
newline;

add('90',tepRotate20,0,'micon.rotate90','Rotate|Rotate image right 90 degrees');
newline;

add('180',tepRotate20,0,'micon.rotate180','Rotate|Rotate image right 180 degrees');
newline;

add('270',tepRotate20,0,'micon.rotate270','Rotate|Rotate image right 270 degrees');
newline;

end;//options

xlabel('Settings','');
isettings:=ntoolbar('');

with isettings do
begin
normal:=true;
ounderline :=false;
oflatback  :=true;
oheadalign:=false;
halign:=0;
oscaleh   :=scale_opts;
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
opopcolor:=true;
oshaderange:=false;
caption:='Color';
osleek:=true;
end;

icolor1:=ncolor('Color','');
with icolor1 do
begin
opopcolor:=true;
oshaderange:=false;
caption:='Color 1';
osleek:=true;
end;

icolor2:=ncolor('Color','');
with icolor2 do
begin
opopcolor:=true;
oshaderange:=false;
caption:='Color 2';
osleek:=true;
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
itol        :=sint('Scan Tolerance','Scan Tolerance|Adjust scan tolerance to remove background pixels',0,130,30,30);
iopac       :=sint('Relative Opacity','Relative Opacity|Adjust image opacity (translucence) - low value for translucence pixels, and high value for opaque pixels',20,1500,255,255);//allow it to boast

ibrightness :=sint('Brightness','Brightness|Adjust image brightness',-100,100,0,0);
icontrast   :=sint('Contrast','Contrast|Adjust image contrast',-100,100,0,0);

ifeat       :=sint('Feather','Feather|Generate a translucent feather|0 = Off| 1..255 = Feather translucent pixels|-1..-255 = Feather all pixels',-255,255,0,0);
iqual       :=sint('Quality','Quality|Adjust image quality',1,30,30,30);
itolCol     :=sint('Color Mix','Color Mix|Adjust threshold point at which visible pixels mix from color 1 to color 2',1,255,1,1);
end;

end;


//.main toolbar
imaintoolbar    :=xhigh2.xtoolbar2;
icaptureindex2  :=gui.rootwin.xhead.add('Capture',tepScreen20,0,'micon.capture',xhelpval('micon.capture'));

with gui.rootwin.xhead do
begin

add('Copy',tepCopy20,0,'micon.copy.png'     ,xhelpval('micon.copy.png'));
add('Paste',tepPaste20,0,'micon.paste'      ,xhelpval('micon.paste'));

addsep;
add('TEA',tepCopy20,0,'micon.copy.tea'      ,xhelpval('micon.copy.tea'));
add('PNG',tepCopy20,0,'micon.copy.b64.png'  ,xhelpval('micon.copy.b64.png'));
add('GIF',tepCopy20,0,'micon.copy.b64.gif'  ,xhelpval('micon.copy.b64.gif'));
addsep;

end;

with imaintoolbar do
begin

oheadalign:=true;
icaptureindex:=add('Capture',tepScreen20,0,'micon.capture',xhelpval('micon.capture'));
add('Open',tepOpen20,0,'micon.open.img','Open|Open source image from file');

add('Clear',tepClose20,0,'micon.clear'      ,'Clear|Clear image');
add('Copy',tepCopy20,0,'micon.copy.png'     ,xhelpval('micon.copy.png'));
add('Copy Source',tepCopy20,0,'micon.copy'  ,'Copy|Copy source image to Clipboard');
add('Paste',tepPaste20,0,'micon.paste'      ,xhelpval('micon.paste'));


addsep;
add('PNG',tepSave20,0,'micon.save.png','Save Image|Save image in PNG format to file');
add('GIF',tepSave20,0,'micon.save.gif','Save Image|Save image in GIF format to file.'+xhelpval('gif.restriction'));
add('ICO',tepSave20,0,'micon.save.ico','Save Image|Save image in ICO format to file');
add('TEA',tepSave20,0,'micon.save.tea','Save Image|Save image in TEA format to file');
addsep;

add('TEA',tepCopy20,0,'micon.copy.tea'      ,xhelpval('micon.copy.tea'));
add('PNG',tepCopy20,0,'micon.copy.b64.png'  ,xhelpval('micon.copy.b64.png'));
add('GIF',tepCopy20,0,'micon.copy.b64.gif'  ,xhelpval('micon.copy.b64.gif'));

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
freeobj(@isource2);
freeobj(@iimage);
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
   xcanpaste,xmustalign,bol1,bol2,bol3,bol4:boolean;
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
bmarked2['micon.flip']:=iflip;
bmarked2['micon.mirror']:=imirror;

bmarked2['micon.rotate0']:=(irotate=0);
bmarked2['micon.rotate90']:=(irotate=90);
bmarked2['micon.rotate180']:=(irotate=180);
bmarked2['micon.rotate270']:=(irotate=270);
end;


with icolormodes do
begin
for p:=0 to ilmax do
begin
bmarked2['micon.mode.'+intstr32(p)]:=(imode=p);
btep2['micon.mode.'+intstr32(p)]   :=tep__tick(imode=p);
end;
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
bol1:=icolor0.visible;
bol2:=icolor1.visible;
bol3:=icolor2.visible;
bol4:=itolCol.visible;

icolor0.visible:=(mode=ilColor);
icolor1.visible:=(mode=ilColor2);
icolor2.visible:=(mode=ilColor2);
itolCol.enabled:=(mode=ilColor2);
itolCol.visible:=(mode=ilColor2);

if (bol1<>icolor0.visible) or (bol2<>icolor1.visible) or (bol3<>icolor2.visible) or (bol4<>itolCol.visible) then xmustalign:=true;


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

procedure tmonoicon.setquality(x:longint);
begin
iquality:=frcrange32(x,0,2);
end;

procedure tmonoicon.setmode(x:longint);
begin
imode:=frcrange32(x,0,ilmax);
end;

procedure tmonoicon.xcopybase64(xindex:longint;dext:string);
label
   skipend;
var
   xresult:boolean;
   a:tbasicimage;
   d:tstr8;
   dtype,e:string;
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
d:=str__new8;
if not xmakedata(xindex,fPNG,@d)           then goto skipend;

if strmatch(dext,'gif') then
   begin

   dtype  :='image/gif';
   a      :=misimg32(1,1);
   if not mis__fromdata(a,@d,e)            then goto skipend;
   if not mis__todata(a,@d,'gif',e)        then goto skipend;

   end
else
   begin

   dtype:='image/png';

   end;

if not str__tob64(@d,@d,0)                 then goto skipend;
if not d.sins('data:'+dtype+';base64,',0)  then goto skipend;
if not clip__copytext(d.text)              then goto skipend;

//successful
xresult:=true;
gui.popstatus(low__mbAUTO2(d.len,1,true)+' of text copied to Clipboard',1);
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

procedure tmonoicon.xcopytea(xindex:longint);
label
   skipend;
var
   xresult:boolean;
   dline,d,d2:tstr8;
   dlen,p:longint;
   e:string;
begin
try
//defaults
xresult :=false;
d       :=nil;
d2      :=nil;
dline   :=nil;
e       :=gecTaskfailed;

//check
if not cancopy then exit;

//get
d     :=str__new8;
d2    :=str__new8;
dline :=str__new8;
if not xmakedata(xindex,fTEA,@d) then goto skipend;
dlen  :=str__len(@d);


//start
d2.sadd( ':array[0..'+intstr32(dlen-1)+'] of byte=('+rcode );

//content
for p:=1 to dlen do
begin
str__sadd(@dline,intstr32(byte(d.bytes1[p]))+insstr(',',p<dlen));

if (str__len(@dline)>=990) then
   begin
   str__add(@d2,@dline);
   str__sadd(@d2,rcode);
   str__clear(@dline);
   end;
end;//p

//.finalise
str__add(@d2,@dline);
str__sadd(@d2,');'+rcode);

//copy
if not clip__copytext(d2.text) then goto skipend;

//successful
xresult:=true;
gui.popstatus(low__mbAUTO2(d2.len,1,true)+' of text copied to Clipboard',1);
skipend:
except;end;
//free
str__free(@d);
str__free(@d2);
str__free(@dline);
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
x:=bolstr(imirror)+bolstr(iflip)+'|'+insstr( intstr32(icliparea.left)+'_'+intstr32(icliparea.top)+'_'+intstr32(icliparea.right)+'_'+intstr32(icliparea.bottom), iclipactive<=0)+'|'+intstr32(irotate)+'|'+intstr32(icolor0.color)+'|'+intstr32(icolor1.color)+'|'+intstr32(icolor2.color)+'|'+intstr32(lcolor2(mode,true))+'|'+intstr32(lcolor(mode,true))+'|'+intstr32(iqual.val)+'|'+intstr32(itolCol.val)+'|'+intstr32(itol.val)+'|'+intstr32(ibrightness.val)+'|'+intstr32(icontrast.val)+'|'+intstr32(ifeat.val)+'|'+intstr32(iopac.val)+'|'+intstr32(iquality)+'|'+intstr32(imode)+'|'+intstr32(ipadw.val)+'|'+intstr32(ipadh.val)+'|'+intstr32(iminw.val)+'|'+intstr32(iminh.val)+'|'+intstr32(ishiftx.val)+'|'+intstr32(ishifty.val);
result:=(x<>isettingsref);
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
   v.i['tol']       :=itol.val;
   v.i['tolcol']    :=itolcol.val;
   v.i['opacity']   :=iopac.val;

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

function tmonoicon.xtabfile(xindex:longint;xpng:boolean):string;
begin
result:=app__settingsfile('tab'+intstr32(xindex)+'.'+low__aorbstr('ini','png',xpng));
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
itol.val        :=v.idef('tol',itol.def);
itolcol.val     :=v.idef('tolcol',itolcol.def);
iopac.val       :=v.idef('opacity',iopac.def);

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

//reset ref
xsettingschanged(true);

//trigger paint
isourcechanged:=true;
except;end;
//free
freeobj(@v);
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
xlen:=low__len(x);

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
   if strmatch('**paste**',sfilename) then
      begin
      if not clip__pasteimage(a) then goto skipend;
      misonecell(a);
      mis__copy(a,isource);
      end
   else if mis__fromfile(a,sfilename,e) then
      begin
      misonecell(a);
      mis__copy(a,isource);
      end
   else missize(a,1,1);
   end;

if misempty(a) then
   begin
   if not misempty(s) then mis__copy(s,isource)
   else
      begin
      missize(isource,32,32);
      mis__cls(isource,0,0,0,0);
      end;
   end;

//max size
if (misw(isource)>isizelimit) or (mish(isource)>isizelimit) then missize(isource,frcmax32(misw(isource),isizelimit),frcmax32(mish(isource),isizelimit));

//save "source" to file
xsavetab2(true,false);

//set
isourcechanged:=true;

skipend:
except;end;
//free
freeobj(@a);
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
ilrgba    :result:=0;
ilrgba2   :result:=0;
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
ilrgba    :result:='RGBA';
ilrgba2   :result:='RGBA2';
else       result:='Black';
end;//case
end;

function tmonoicon.lhelp(xindex:longint):string;//31oct2025
const
   xshadesof ='Convert all visible image pixels into shades of ';
   xrgba     ='Convert all visible image pixels into RGB shades based on generated average values and Relative Opacity value';
   xrgba2    ='Convert all visible image pixels into RGB shades based on generated inverted average values and Relative Opacity value';
begin
case xindex of
ilblack   :result:=xshadesof+'black';
ilwhite   :result:=xshadesof+'white';
ilBW      :result:=xshadesof+'black and white';
ilcolor   :result:=xshadesof+'custom color';
ilcolor2  :result:=xshadesof+'custom colors 1 and 2. Colors are mixed via pixel luminosity and Color Mix value.';
ilfont    :result:=xshadesof+'app font color. Use this color mode to generate "TEA" images using a Gossamer app''s font color. Any change to the app''s font color renders automatically in realtime.';//24oct2025
ilrgba    :result:=xrgba;
ilrgba2   :result:=xrgba2;
else       result:=xshadesof+'black';
end;//case
end;

function tmonoicon.xmakeimage(d:tobject;xindex:longint;xdemo:boolean):boolean;
begin
result:=xmakeimage2(d,xindex,ishiftx.val,ishifty.val,itolCol.val,itol.val,ifeat.val,iopac.val,ipadw.val,ipadh.val,iqual.val,ibrightness.val,icontrast.val,iminw.val,iminh.val,xdemo);
end;

function tmonoicon.xmakeimage2(d:tobject;xindex,dshiftx,dshifty,dtolCol,dtol,dfeather,dopacity,wautopad,hautopad,dquality,dbrightness100,dcontrast100,dw,dh:longint;xdemo:boolean):boolean;
label
   skipend;
var
   e:string;
   ssource:trawimage;//pointer only
   s:trawimage;
   m,mf,mf24:tbasicimage;
   b:tstr8;
   tr,tg,tb,vmax,int1,int2,v,v1,v2,v3,uw,uh,sx,sy,xshift,yshift,p,p2,p3,sw,sh,dx,dy:longint;
   s32:array[0..7] of tcolor32;
   xchecker,bol1,vinv:boolean;
   vratio:extended;
   c24:tcolor24;
   d32,d322,c32:tcolor32;
   frs8,mrs8:pcolorrows8;
   frs24:pcolorrows24;
   srs32,drs32:pcolorrows32;

   function q(x:byte):byte;//quality
   begin
   result:=x;

   if (dquality>=2) and (result<>0) and (result<>255) then
         begin
         result:=(result div dquality)*dquality;
         if (result<=0) then result:=1 else if (result>=255) then result:=254;
         end;
   end;

   function vave(const x:tcolor32):byte;
   var
      vmin,vmax:byte;
   begin
   vmin:=x.r;
   if (x.g<vmin) then vmin:=x.g;
   if (x.b<vmin) then vmin:=x.b;

   vmax:=x.r;
   if (x.g>vmax) then vmax:=x.g;
   if (x.b>vmax) then vmax:=x.b;


   if ((vmax-vmin)>=200) then
      begin
//      result:=frcrange32( round(255-vmax*(255/frcmin32(vmax-vmin,1)) ) ,0,255);
      result:=255-vmax;
      end
   else
      begin
      result:=(x.r+x.g+x.b) div 3;
      if vinv then result:=255-result;
      end;

   end;

   function cok32(const x:tcolor32):boolean;//is a color
   var
      v:longint;
   begin
   result:=false;

   //.r-g
   v:=x.r-x.g;
   if (v<0) then v:=-v;
   if (v>=dtolCol) then
      begin
      result:=true;
      exit;
      end;

   //.r-b
   v:=x.r-x.b;
   if (v<0) then v:=-v;
   if (v>=dtolCol) then
      begin
      result:=true;
      exit;
      end;

   //.g-b
   v:=x.g-x.b;
   if (v<0) then v:=-v;
   if (v>=dtolCol) then
      begin
      result:=true;
      exit;
      end;
   end;

   function tok32(const x:tcolor32):boolean;//is transparent
   begin
   result:=(tr>=0) and (x.r>=(tr-dtol)) and (x.r<=(tr+dtol)) and (x.g>=(tg-dtol)) and (x.g<=(tg+dtol)) and (x.b>=(tb-dtol)) and (x.b<=(tb+dtol));
   end;

   function sw1:longint;
   var
      dx,dy:longint;
   begin
   result:=0;

   for dx:=0 to (sw-1) do for dy:=0 to (sh-1) do if (mrs8[dy][dx]>=1) then
      begin
      result:=dx;
      exit;
      end;
   end;

   function sw2:longint;
   var
      dx,dy:longint;
   begin
   result:=0;

   for dx:=(sw-1) downto 0 do for dy:=0 to (sh-1) do if (mrs8[dy][dx]>=1) then
      begin
      result:=frcmin32(sw-dx-1,0);
      exit;
      end;
   end;

   function sh1:longint;
   var
      dx,dy:longint;
   begin
   result:=0;

   for dy:=0 to (sh-1) do for dx:=0 to (sw-1) do if (mrs8[dy][dx]>=1) then
      begin
      result:=dy;
      exit;
      end;
   end;

   function sh2:longint;
   var
      dx,dy:longint;
   begin
   result:=0;

   for dy:=(sh-1) downto 0 do for dx:=0 to (sw-1) do if (mrs8[dy][dx]>=1) then
      begin
      result:=frcmin32(sh-dy-1,0);
      exit;
      end;
   end;

   procedure mblur24;
   var
      sx,sy:longint;
      dr,dg,db,dc:longint;

      procedure xadd(x,y:longint);
      var
         c32:tcolor32;
      begin
      if (x>=0) and (x<sw) and (y>=0) and (y<sh) and (mrs8[y][x]>=1) then
         begin
         c32:=srs32[y][x];
         inc(dr,c32.r);
         inc(dg,c32.g);
         inc(db,c32.b);
         inc(dc,1);
         end;
      end;
   begin
   if (mf24=nil) then exit;

   for sy:=0 to (sh-1) do
   begin

   for sx:=0 to (sw-1) do
   begin
   //reset
   dr:=0;
   dg:=0;
   db:=0;
   dc:=0;

   //add
   xadd(sx-1,sy-1);
   xadd(sx+0,sy-1);
   xadd(sx+1,sy-1);

   xadd(sx-1,sy+0);
   xadd(sx+0,sy+0);
   xadd(sx+1,sy+0);

   xadd(sx-1,sy+1);
   xadd(sx+0,sy+1);
   xadd(sx+1,sy+1);

   //set
   if (dc>=1) then
      begin
      c24.r:=dr div dc;
      c24.g:=dg div dc;
      c24.b:=db div dc;
      frs24[sy][sx]:=c24;
      end;
   end;//sx

   end;//sy

   end;
begin
//defaults
result :=true;//pass-thru
m      :=nil;
mf     :=nil;
mf24   :=nil;
b      :=nil;
tr     :=-1;
tg     :=-1;
tb     :=-1;
vinv   :=false;
ssource:=isource;

//check
if not misok32(isource,sw,sh)      then exit;
if not misok32(isource2,int1,int2) then exit;
if not misok32(d,int1,int2)        then exit;

try
//clip source
int1:=icliparea.right-icliparea.left;
int2:=icliparea.bottom-icliparea.top;
if (int1>=2) and (int2>=2) then
   begin
   missize(isource2,int1,int2);
   if not mis__copyfast82432(maxarea,0,0,int1,int2,area__make(icliparea.left,icliparea.top,icliparea.right-1,icliparea.bottom-1),isource2,isource) then goto skipend;
   ssource:=isource2;
   sw:=misw(isource2);
   sh:=mish(isource2);
   end;

//range
xindex         :=frcrange32(xindex,0,ilmax);
dw             :=frcmin32(dw,1);
dh             :=frcmin32(dh,1);
dtol           :=frcrange32(dtol,0,130);
dtolCol        :=frcrange32(dtolCol,1,255);//24oct2025
dfeather       :=frcrange32(dfeather,-255,255);
dopacity       :=frcrange32(dopacity,20,1500);//allow it to boast
dquality       :=31-frcrange32(dquality,1,30);//30=best and 1=worst
dbrightness100 :=frcrange32(dbrightness100,-100,100);
dcontrast100   :=frcrange32(dcontrast100,-100,100);
d32            :=int__c32(lcolor(xindex,xdemo));
d322           :=int__c32(lcolor2(xindex,xdemo));//2nd system color
s              :=ssource;

//s
if (wautopad>=1) or (hautopad>=1) then
   begin
   int1:=insint(1,(wautopad>=1));
   int2:=insint(1,(hautopad>=1));
   sw  :=sw+(2*int1);
   sh  :=sh+(2*int1);
   s:=misraw32(sw,sh);
   c32:=mispixel32(ssource,0,0);
   mis__cls(s,c32.r,c32.g,c32.b,c32.a);
   if not mis__copyfast82432(maxarea,int1,int2,misw(ssource),mish(ssource),misarea(ssource),s,ssource) then goto skipend;
   end
else s:=ssource;

//m
m:=misimg8(sw,sh);
mis__cls(m,0,0,0,0);

if (dfeather<>0) then
   begin
   mf:=misimg8(sw,sh);
   mis__cls(mf,0,0,0,0);

   //m24
   if (xindex=ilrgba) or (xindex=ilrgba2) then
      begin
      mf24:=misimg24(sw,sh);
      mis__cls(mf24,0,0,0,0);
      if not mis__copyfast82432(maxarea,0,0,sw,sh,misarea(s),mf24,s) then goto skipend;
      end;
   end;

if not misrows32(s,srs32)                       then goto skipend;
if not misrows8(m,mrs8)                         then goto skipend;
if (mf<>nil) and (not misrows8(mf,frs8))        then goto skipend;
if (mf24<>nil) and (not misrows24(mf24,frs24))  then goto skipend;

//scan
vmax:=0;

for sy:=0 to (sh-1) do for sx:=0 to (sw-1) do
   begin
   c32:=srs32[sy][sx];

   if (sy=0) and (sx=0) then
      begin
      tr:=c32.r;
      tg:=c32.g;
      tb:=c32.b;
      vinv:=(c32__lum(c32)<100);
      if (xindex=ilrgba2) then vinv:=not vinv;//24may2025
      end;

   if not tok32(c32) then
      begin
      v:=255-vave(c32);
      if (v>vmax) then vmax:=v;
      end;
   end;//sy

//make
vratio:=255/frcmin32(vmax,1);

for sy:=0 to (sh-1) do for sx:=0 to (sw-1) do
   begin
   c32:=srs32[sy][sx];

   if not tok32(c32) then
      begin
      //get
      v:=255-vave(c32);
      v:=round(v*vratio);
      if (v<0) then v:=0 else if (v>255) then v:=255;
      //set
      mrs8[sy][sx]:=v;
      if (mf<>nil) then frs8[sy][sx]:=v;
      end;

   end;//sy

//calc offsets for centering "s" on "d"
//.h
v1    :=sh1;
v2    :=sh2;
v3    :=sh-v1-v2;
uh    :=frcmin32(sh-v1-v2,1);
dh    :=largest32(dh,uh);
if (hautopad>=0) then dh:=frcmin32((2*hautopad)+dh,1);
yshift:=((uh-dh) div 2)+v1;

//.w
v1    :=sw1;
v2    :=sw2;
v3    :=sw-v1-v2;
uw    :=frcmin32(sw-v1-v2,1);
dw    :=largest32(dw,uw);
if (wautopad>=0) then dw:=frcmin32((2*wautopad)+dw,1);
xshift:=((uw-dw) div 2)+v1;

//feather
if (mf<>nil)   then misblur82432(mf);
if (mf24<>nil) then misblur82432(mf24);

//d
missize(d,dw,dh);
mis__cls(d,d32.r,d32.g,d32.b,0);

//d.rows
if not misrows32(d,drs32) then goto skipend;

//.blur for ilRGBA/ilRGBA2
if (mf24<>nil) and (dfeather<>0) then mblur24;

//scan
sy:=yshift-dshifty;

for dy:=0 to (dh-1) do
begin
xchecker:=low__iseven(dy);

if (sy>=0) and (sy<sh) then
   begin
   sx:=xshift-dshiftx;

   for dx:=0 to (dw-1) do
   begin

   if (sx>=0) and (sx<sw) then
      begin
      //get
      v:=round((dopacity/255)*mrs8[sy][sx]);
      if (v<0) then v:=0 else if (v>255) then v:=255;

      if (mf<>nil) then
         begin
         if (dfeather>=1) then
            begin
            v2:=round((dfeather/255)*(dopacity/255)*frs8[sy][sx]);
            if (v2<0) then v2:=0 else if (v2>255) then v2:=255;
            if (v2>v) then v:=v2;
            end
         else
            begin
            v2:=round((dopacity/255)*frs8[sy][sx]);
            v:=( (v*(255+dfeather)) + (v2*-dfeather) ) div 256;
            if (v<0) then v:=0 else if (v>255) then v:=255;
            end;
         end;

      //set
      if (xindex=ilrgba) or (xindex=ilrgba2) then
         begin
         //get
         c32:=srs32[sy][sx];
         bol1:=tok32(c32);

         //.ilRGBA feather pixel color
         if (mf24<>nil) and (c32.a>=1) and ( (dfeather<=-1) or (bol1 and (dfeather>=1)) ) then
            begin
            c24:=frs24[sy][sx];
            c32.r:=q(c24.r);
            c32.g:=q(c24.g);
            c32.b:=q(c24.b);
            end
         //.transparent pixel color
         else if bol1 then
            begin
            c32.r:=0;
            c32.g:=0;
            c32.b:=0;
            end
         //.visible pixel color
         else
            begin
            c32.r:=q(c32.r);
            c32.g:=q(c32.g);
            c32.b:=q(c32.b);
            end;
         //.common alpha pixel value
         c32.a:=q(v);

         //set
         drs32[dy][dx]:=c32;
         end
      else if (xindex=ilBW) then
         begin
         if xchecker then
            begin
            d322.a:=q(v);
            drs32[dy][dx]:=d322;
            end
         else drs32[dy][dx].a:=q(v);
         end
      else if (xindex=ilColor2) then
         begin
         //.color detected -> switch to system font color 2 (0,0,1) + alpha value
         if cok32(srs32[sy][sx]) then
            begin
            d322.a       :=q(v);
            drs32[dy][dx]:=d322;
            end
         //.non-color detected -> use default system font color 1 (already applied) -> set alpha value only
         else drs32[dy][dx].a:=q(v);
         end
      //.all other ilModes
      else drs32[dy][dx].a:=q(v);
      end;

   //inc
   inc(sx);
   xchecker:=not xchecker;
   end;//dx

   end;

//inc
inc(sy);
end;//dy

//finalise
if (dbrightness100<>0) or (dcontrast100<>0) then mis__brightness_contrast32(d,dbrightness100,dcontrast100,xindex);//31oct2025

if imirror      then mis__mirror82432(d);
if iflip        then mis__flip82432(d);
if (irotate<>0) then mis__rotate82432(d,irotate);

skipend:
except;end;
//free
if (s<>isource) and (s<>isource2) then freeobj(@s);
freeobj(@m);
freeobj(@mf);
freeobj(@mf24);
str__free(@b);
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
fgif:if not mis__todata(d,xdata,'gif',e)                       then goto skipend;
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
   b:tstr8;
   xmustflash,xmustpaint:boolean;
begin
try
//defaults
b:=nil;
xmustpaint:=false;
xmustflash:=false;

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

   //detect changes
   if iloaded and (xsettingschanged(true) or isourcechanged) then
      begin
      try
      //reset
      isourcechanged:=false;

      //save tab
      xsavetab;

      //init
      xmakeimage(iimage,imode,true);
      b:=str__new8;

      //get
      //.png
      xmakedata(mode,fPNG,@b);
      ibytesPNG:=str__len(@b);

      //.gif
      xmakedata(mode,fGIF,@b);
      ibytesGIF:=str__len(@b);

      //.ico
      xmakedata(mode,fICO,@b);
      ibytesICO:=str__len(@b);

      //.tea
      xmakedata(mode,fTEA,@b);
      ibytesTEA:=str__len(@b);

      //.colors
      icolors      :=miscountcolors(iimage);
      imaskshades  :=mask__count(iimage);

      except;end;

      //buttons
      xupdatebuttons;

      //paint
      xmustpaint:=true;
      end;

   //reset
   itimer100:=add64(ms64,100);
   end;

//paint
if      xmustpaint then paintnow
else if xmustflash then iscreen.paintnow;

except;end;
//free
if (b<>nil) then freeobj(@b);
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

   result:=frcrange32(round( sub64(icapturemoveref,ms64)/frcmin64(0.01*xcapturetime,1) ),0,100);

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
result:=clip__canpasteimage;
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
xmustpaint:=false;
v         :='';
v32       :=0;

//check
if cancmd(x) then x:=strcopy1(x,7,low__len(x)) else exit;

//get
if m('resample') then
   begin

   xmustpaint:=true;

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
else if m('copy.tea') then xcopytea(mode)
else if m('copy') then
   begin
   if cancopy then clip__copyimage(isource);
   end
   
else if m('paste') then
   begin
   icliparea:=nilarea;
   xloadimg(nil,'**paste**');
   end
else if mv('mode.') then
   begin
   mode:=v32;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if mv('tabslot.') then
   begin
   tabslot:=v32;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if m('mirror') then
   begin
   imirror:=not imirror;
   xupdatebuttons;
   end
else if m('flip') then
   begin
   iflip:=not iflip;
   xupdatebuttons;
   end
else if m('rotate0') then
   begin
   irotate:=0;
   xupdatebuttons;
   end
else if m('rotate90') then
   begin
   irotate:=90;
   xupdatebuttons;
   end
else if m('rotate180') then
   begin
   irotate:=180;
   xupdatebuttons;
   end
else if m('rotate270') then
   begin
   irotate:=270;
   xupdatebuttons;
   end
else if m('pngquality') then
   begin
   int1:=quality+1;
   if (int1>2) then int1:=0;
   quality:=int1;
   isourcechanged:=true;
   end
else if m('fastcapture') then
   begin
   ifastcapture:=not ifastcapture;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if m('checker') then
   begin
   ishowchecker:=not ishowchecker;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if m('frame') then
   begin
   ishowframe:=not ishowframe;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if m('framesm') then
   begin
   ishowframesm:=not ishowframesm;
   xupdatebuttons;
   xmustpaint:=true;
   end
else if m('swapcols') then
   begin
   int1:=icolor2.color;
   icolor2.color:=icolor1.color;
   icolor1.color:=int1;
   xupdatebuttons;
   xmustpaint:=true;
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
procedure tmonoicon.xscreen__onpaint(sender:tobject);
const
   xlinespacing=1.2;
var
   a:tclientinfo;
   xframe,xframesm:boolean;
   denlargedview,ca,da:twinrect;
   ai:tobject;
   dcolw,dtextrightmostx,vsep,dright,dbottom,aw,ah,int1,int2,v,ox,oy,p,hpad,vpad,dx,dy,dy0:longint;
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

      iscreen.ldtTAB2(clnone,dtab,a.ci,dx,dy,a.font,x,a.fn,a.f,false,false,false,false,a.r);

      dtextrightmostx:=largest32(dtextrightmostx, dx + low__fonttextwidthTAB2(dtab, a.fn, x) );

      end;

   inc(dy, trunc(a.fnH*xlinespacing) );

   end;

   procedure xdraw(d:tobject;var dx,dy,dwidth:longint;const denlargedview:boolean;xzoomfactor:longint;xcap:string;xbackcolor:longint);//07nov2025
   var
      x1,x2,y1,y2,dbits,ddw,ddh,dw,dh,int1,tx,ty,v:longint;
   begin

   //defaults
   dwidth:=0;

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
   if (xbackcolor<>clnone) then iscreen.ldso2(area__grow(da,1),clnone,clnone,xbackcolor,xbackcolor,clnone,0,'',false);

   //frame
   if (xframe and (xzoomfactor>1)) or (xframesm and (xzoomfactor<=1)) then
      begin

      int1:=1;
      v:=int__splice24(0.5,a.font,a.back);
      iscreen.ldo(area__grow(da,1),v,false);

      end
   else int1:=0;

   iscreen.ldbEXCLUDE(true,area__grow(da,int1),false);

   //title
   if (xcap<>'') then iscreen.ldtTAB2(clnone,tbnone,a.ci,tx,ty,a.font,xcap,a.fn,a.f,false,false,false,false,a.r);

   //checkerboard image
   v:=insint(igridsize,iflashON);
   if (xbackcolor=clnone) then iscreen.ldc32(da,da.left,da.top,ddw,ddh,area__make(0,v,ddw-1,v+ddh-1),igrid,255,false);

   //user image
   iscreen.ldc32b(da,da.left,da.top,ddw,ddh,misarea(d),d,255,(not denlargedview) or (iclipactive=0),false);//disable transparency whilst in "clip source" mode - Win98

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
      iscreen.ldo(ca,clwhite,false);
      iscreen.ldo(area__grow(ca,1),clblack,false);
      iscreen.ldo(area__grow(ca,2),clwhite,false);
      end;


   inc(dy,ddh);
   inc(dy,vsep);

   //bottom space
   inc(dy,2*vsep);

   if (xcap<>'') then v:=low__fonttextwidth2(a.fn,xcap) else v:=0;
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
   0:s('Checker',clnone);
   1:s('Window Client',a.back);
   2:s('Window Head',viTitle.mback);
   3:s('Black',0);
   4:s('Grey',rgba0__int(128,128,128));
   5:s('White',rgba0__int(255,255,255));
   6:s('Red',rgba0__int(255,0,0));
   7:s('Yellow',rgba0__int(255,255,0));
   8:s('Blue',rgba0__int(0,0,255));
   9:s('Green',rgba0__int(0,255,0));
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
xframe      :=ishowframe;
xframesm    :=ishowframesm;
vsep        :=3*a.zoom;

//cls
iscreen.lds(a.cs,a.back,false);

//enlarged view
//.dynamic zoom
v                    :=frcrange32( 450 div frcmin32(largest32(aw,ah),1) ,1,izoomlimit);

//.draw enalarged view
xdraw(ai,dx,dy,int2,true,v,'Enlarged View - '+low__aorbstr(llabel(mode)+' at '+k64(v*100)+'%','Adjust Capture Area',iclipactive>=1),low__aorb(a.back,clnone,ishowchecker));
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
xdrawtext(dx,dy,xtab,'ICO'+#9+'32 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesICO)+' b');
xdrawtext(dx,dy,xtab,'TEA'+#9+'32 bpp'+#9+k64(misw(iimage))+'w x '+k64(mish(iimage))+'h'+#9+k64(ibytesTEA)+' b');
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
   xdraw(iimage,dx,dy,int2,false,1,str1,int1);

   //track dynamic column width -> text.width and image.width(int2)
   dcolw:=largest32( dcolw, largest32( low__fonttextwidth2( a.fn, str1), int2 ) );

   end;

end;//p


//corners
iscreen.xparentcorners;

except;end;

//free
freeobj(@xtmp);

end;


//## tapp ######################################################################
constructor tapp.create;
begin
if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')),true);

ibuildingcontrol   :=true;
iloaded            :=false;
isettingsref       :='';
icouldcapture      :=false;

//need checkers
need_jpeg;
need_gif;
need_ico;

//init
itimer500          :=ms64;


//controls
with rootwin do
begin
static:=true;
xhead;
xgrad;
xgrad2;
xstatus2.celltext[0]:=app__info('des');
xstatus2.cellalign[0]:=0;

icore:=tmonoicon.create(client);
end;//rootwin


with rootwin do
begin
xhead.xaddoptions;
xhead.xaddhelp;
end;


//default page to show
rootwin.xhead.parentpage:='overview';

//events
rootwin.xhead.onclick:=__onclick;
rootwin.xhead.showmenuFill1:=xshowmenuFill1;
rootwin.xhead.showmenuClick1:=xshowmenuClick1;
rootwin.xhead.ocanshowmenu:=true;//use toolbar for special menu display - 18dec2021
rootwin.onaccept:=icore._onaccept;//drag and drop support

//start timer event
ibuildingcontrol:=false;
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
e:='';

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

end.
