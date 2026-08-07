
unit _SDL_SavePNG;

interface

uses
  SDL,
  png,
  SysUtils;

const
  SUCCESS = 0;
  ERROR = -1;

  {$IFDEF SDL_BIG_ENDIAN}
  rmask = $FF000000;
  gmask = $00FF0000;
  bmask = $0000FF00;
  amask = $000000FF;
  {$ELSE}
  rmask = $000000FF;
  gmask = $0000FF00;
  bmask = $00FF0000;
  amask = $FF000000;
  {$ENDIF}

  // Константы libpng (должны быть определены в заголовочном файле)
  PNG_COLOR_MASK_COLOR = 2;
  PNG_COLOR_MASK_PALETTE = 1;
  PNG_COLOR_MASK_ALPHA = 4;
  PNG_INTERLACE_NONE = 0;
  PNG_COMPRESSION_TYPE_DEFAULT = 0;
  PNG_FILTER_TYPE_DEFAULT = 0;

//procedure png_error_SDL(ctx: png_structp; str: png_const_charp); cdecl;
procedure png_write_SDL(png_ptr: png_structp; data: png_bytep; length: png_size_t); cdecl;
function SDL_SavePNG_RW(surface: PSDL_Surface; dst: PSDL_RWops; freedst: Integer): Integer;
function SDL_SavePNG(surface: PSDL_Surface; filename: PChar): Integer;
function SDL_PNGFormatAlpha(src: PSDL_Surface): PSDL_Surface;

implementation

function SDL_PNGFormatAlpha(src: PSDL_Surface): PSDL_Surface;
var
  surf: PSDL_Surface;
  rect: TSDL_Rect;
begin
  rect.x := 0;
  rect.y := 0;
  rect.w := 0;
  rect.h := 0;

  // NO-OP для изображений < 32bpp и 32bpp с альфа-каналом
  if(src^.format^.BitsPerPixel<=24)
  or(src^.format^.Amask<>0)then
  begin
    src^.refcount:=src^.refcount+1;
    Result:=src;
    Exit;
  end;

  rect.w := src^.w;
  rect.h := src^.h;
  surf:=SDL_CreateRGBSurface(src^.flags, src^.w, src^.h, 24,
    src^.format^.Rmask, src^.format^.Gmask, src^.format^.Bmask, 0);
  SDL_LowerBlit(src, @rect, surf, @rect);

  Result := surf;
end;


{procedure png_error_SDL(ctx: png_structp; str: png_const_charp); cdecl;
begin
  SDL_SetError('libpng: %s');
end;}

procedure png_write_SDL(png_ptr: png_structp; data: png_bytep; length: png_size_t); cdecl;
var
  rw: PSDL_RWops;
begin
  rw := PSDL_RWops(png_get_io_ptr(png_ptr));
  SDL_RWwrite(rw, data, SizeOf(png_byte), length);
end;

function SDL_SavePNG_RW(surface: PSDL_Surface; dst: PSDL_RWops; freedst: Integer): Integer;
var
png_ptr     : png_structp;
info_ptr    : png_infop;
pal_ptr     : png_colorp;
pal         : PSDL_Palette;
i           : Integer;
colortype   : Integer;
row_pointers: array of png_bytep;
begin
   if(dst=nil)then
   begin
      SDL_SetError('Argument 2 to SDL_SavePNG_RW can`t be NULL, expecting SDL_RWops*');
      Result:=ERROR;
      Exit;
   end;

   if(surface=nil)then
   begin
      SDL_SetError('Argument 1 to SDL_SavePNG_RW can`t be NULL, expecting SDL_Surface*');
      if(freedst<>0)then
        SDL_RWclose(dst);
      Result := ERROR;
      Exit;
   end;

   png_ptr:=png_create_write_struct(PNG_LIBPNG_VER_STRING, nil, nil, nil);   //@png_error_SDL
   if(png_ptr=nil)then
   begin
      SDL_SetError('Unable to png_create_write_struct on %s');
      if(freedst<>0)then
        SDL_RWclose(dst);
      Result := ERROR;
      Exit;
   end;

   info_ptr:=png_create_info_struct(png_ptr);
   if(info_ptr=nil)then
   begin
      SDL_SetError('Unable to png_create_info_struct');
      png_destroy_write_struct(@png_ptr, nil);
      if freedst <> 0 then
        SDL_RWclose(dst);
      Result := ERROR;
      Exit;
   end;

   png_set_write_fn(png_ptr, dst, @png_write_SDL, nil);

   colortype := PNG_COLOR_MASK_COLOR;

   pal:=surface^.format^.palette;

   if(surface^.format^.BytesPerPixel> 0)and
     (surface^.format^.BytesPerPixel<=8)and
     (pal<>nil)then
   begin
      colortype:=colortype or PNG_COLOR_MASK_PALETTE;
      GetMem(pal_ptr,pal^.ncolors*SizeOf(png_color));
      for i:=0 to pal^.ncolors-1 do
      begin
         pal_ptr[i].red  := pal^.colors^[i].r;
         pal_ptr[i].green:= pal^.colors^[i].g;
         pal_ptr[i].blue := pal^.colors^[i].b;
      end;
      png_set_PLTE(png_ptr, info_ptr, pal_ptr, pal^.ncolors);
      FreeMem(pal_ptr);
   end
   else
     if(surface^.format^.BytesPerPixel>3)
     or(surface^.format^.Amask<>0)then
       colortype := colortype or PNG_COLOR_MASK_ALPHA;

   png_set_IHDR(png_ptr, info_ptr, surface^.w, surface^.h, 8, colortype,
     PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

   if(surface^.format^.Rmask=bmask)and
     (surface^.format^.Gmask=gmask)and
     (surface^.format^.Bmask=rmask)then
      png_set_bgr(png_ptr);

   png_write_info(png_ptr, info_ptr);

   SetLength(row_pointers, surface^.h);
   for i := 0 to surface^.h - 1 do
     row_pointers[i] := png_bytep(PByte(surface^.pixels) + i * surface^.pitch);

   png_write_image(png_ptr, @row_pointers[0]);

   SetLength(row_pointers, 0);

   png_write_end(png_ptr, info_ptr);

   png_destroy_write_struct(@png_ptr, @info_ptr);
   if(freedst<>0)then
     SDL_RWclose(dst);

   Result := SUCCESS;
end;

function SDL_SavePNG(surface: PSDL_Surface; filename: PChar): Integer;
begin
   SDL_SavePNG:=SDL_SavePNG_RW(surface, SDL_RWFromFile(filename, 'wb'), 1);
end;

end.



