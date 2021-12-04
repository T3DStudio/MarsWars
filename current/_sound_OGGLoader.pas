

unit _sound_OGGLoader;

interface

uses sysutils,openal,ogg,vorbis, ctypes, classes;

function LoadOGGData(
    fname:shortstring;
    pSLformat:pALenum;
    pSLdata  :pALvoid;
    pSLsize,
    pSLfreq  :pALsizei;
    errormes :pshortstring):boolean;
function FreeOGGData(
    pSLdata  :pALvoid;
    pSLsize  :pALsizei):boolean;

implementation


(* Reader functions for ov_callbacks *)

type LTStream = TFileStream;

function i2s (i:integer ):shortstring;begin str(i,i2s );end;

function streamSeek(h: Pointer; off: ogg_int64_t; whence: cint): cint; cdecl;
var S:LTStream;
begin
  Result:=-1;
  if(h=nil)then exit;
  S:=LTStream(h);
  try
    case whence of
      0: s.Seek(off, soBeginning); // SEEK_SET
      1: s.Seek(off, soCurrent  ); // SEEK_CUR
      2: s.Seek(off, soEnd      ); // SEEK_END
    end;
    Result:= 0;
  except
    Result:= -1;
  end;
end;

function streamRead(buf: Pointer; sz, nmemb: csize_t; h: Pointer): csize_t; cdecl;
var S:LTStream;
begin
  Result:=0;
  if(h=nil)then exit;
  S:=LTStream(h);
  try
    Result:= S.Read(buf^, sz*nmemb) div sz;
  except
    Result:= 0;
  end;
end;

function streamTell(h: Pointer): clong; cdecl;
var S:LTStream;
begin
  Result:=-1;
  if(h=nil)then exit;
  S:=LTStream(h);
  Result:=S.Position;
end;

var
  oggIO: ov_callbacks = (
    read  : read_func(streamRead);
    seek  : seek_func(streamSeek);
    close : nil;
    tell  : tell_func(streamTell);
  );

function LoadOGGData(
      fname:shortstring;
      pSLformat:pALenum;
      pSLdata  :pALvoid;
      pSLsize,
      pSLfreq  :pALsizei;
      errormes :pshortstring):boolean;
var
oggfile : LTStream;
FOgg    : OggVorbis_File;
Info    : pvorbis_info;
size,
offset,
sel     : size_t;
t:integer;

begin
   result:=false;

   oggfile:=LTStream.Create(fname,fmOpenRead);

   t:=ov_open_callbacks(oggfile, FOgg, nil, 0, oggIO);
   if(t>=0)then
   begin
      Info:=ov_info(FOgg, -1);
      if(Info<>nil)then
      begin
         if(info^.channels=1)
         then pSLformat^:=AL_FORMAT_MONO16
         else pSLformat^:=AL_FORMAT_STEREO16;

         pSLsize^:=ov_pcm_total(FOgg,-1)*info^.channels*2;
         pSLfreq^:=info^.rate;

         pSLdata^:=GetMem(pSLsize^);
         if(pSLdata^<>nil)then
         begin
            size   := 0;
            offset := 0;
            sel    := 0;

            while true do
            begin
               size:= ov_read(FOgg, pSLdata^ + offset, 4096, false, 2, true, @sel);
               offset += size;
               if(size<=0)then break;
            end;

            result:=true;
         end
         else
           if(errormes<>nil)then errormes^:='GetMem()=nil';
      end
      else
        if(errormes<>nil)then errormes^:='ov_info()=nil';
      ov_clear(FOgg);
   end
   else
     if(errormes<>nil)then errormes^:='ov_open_callbacks()='+i2s(t);

   oggfile.Destroy;
end;

function FreeOGGData(
    pSLdata  :pALvoid;
    pSLsize  :pALsizei):boolean;
begin
   try
      FreeMem(pSLdata^,pSLsize^);
      result:=true;
   except
      result:=false;
   end;
end;

end.


