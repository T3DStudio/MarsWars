
procedure str2set(s:shortstring;pts:PTSob);
var p,
    l:byte;
    v,
    u:shortstring;
begin
   l:=length(s);
   while(l>0)do
   begin
      v:='';
      p:=pos(',',s);
      if(p>0)then
      begin
         v:=copy(s,1,p-1);
         delete(s,1,p);
      end
      else
      begin
         v:=s;
         delete(s,1,l);
      end;

      while (true) do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      if(v<>'')then
      begin
         p:=pos('-',v);
         if(p>0)then
         begin
            u:=copy(v,1,p-1);
            delete(v,1,p);
            if(u<>'')and(v<>'')then
            begin
               p:=s2b(u);
               l:=s2b(v);
               while (true) do
               begin
                  pts^:=pts^+[p];
                  if(p=l)
                  then break
                  else p+=sign(l-p);
               end;
            end;
         end
         else pts^:=pts^+[s2b(v)];
      end;

      l:=length(s);
   end;
end;

procedure str2lrgb(s:shortstring;_otp:byte);
var p,a,lq,r,g,b,
    l:byte;
    v:shortstring;
begin
   a :=0;
   r :=0;
   g :=0;
   b :=0;
   lq:=0;
   l :=length(s);
   while(l>0)do
   begin
      v:='';
      p:=pos(',',s);
      if(p>0)then
      begin
         v:=copy(s,1,p-1);
         delete(s,1,p);
         l+=p;
      end
      else
      begin
         v:=s;
         delete(s,1,l);
         l:=0;
      end;

      while (true) do
      begin
         p:=pos(' ',v);
         if(p=0)
         then break
         else delete(v,p,1);
      end;

      case _otp of
      0: case a of
         0: lq:=s2b(v);
         1: r :=s2b(v);
         2: g :=s2b(v);
         3: begin
               b :=s2b(v);
               if(ans_Liquids[lq]=0)then ans_Liquids[lq]:=1;
               map_Liquidc[lq]:=rgba2c(r,g,b,255);
            end;
         4: anm_Liquids[lq]:=s2b(v);
         5: ans_Liquids[lq]:=s2b(v);
         end;
      1: case a of
         0: lq:=s2b(v);
         1: shd_TDecs[lq]:=s2i(v);
         end;
      2: case a of
         0: lq:=s2b(v);
         1: anb_Terrain[lq]:=s2b(v);
         2: ans_Terrain[lq]:=s2b(v)>0;
         end;

      3: case a of
         0: lq:=s2b(v);
         1: tdecs_animt[lq]:=s2b(v);
         2: tdecs_animn[lq]:=s2b(v);
         3: tdecs_ys   [lq]:=s2i(v);
         end;
      4: case a of
         0: lq:=s2b(v);
         1: srocks_animt[lq]:=s2b(v);
         2: srocks_animn[lq]:=s2b(v);
         end;
      5: case a of
         0: lq:=s2b(v);
         1: brocks_animt[lq]:=s2b(v);
         2: brocks_animn[lq]:=s2b(v);
         end;
      end;

      a+=1;
   end;
end;

function insertColorChars(s:shortstring):shortstring;
var c:char;
begin
   for c:=#14 to #25 do s:=stringreplace(s,'#'+b2s(ord(c)),c+'',[rfReplaceAll, rfIgnoreCase]);
   insertColorChars:=s;
end;

function _chstr(ps,pss:pshortstring):boolean;
begin
   _chstr:=false;
   if(pos(pss^,ps^)=1)then
   begin
      delete(ps^,1,length(pss^));
      _chstr:=true;
   end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure _loadMapThemes;
const
  _theme : shortstring = 'theme ';
  _terra : shortstring = 'terrain ';
  _liqui : shortstring = 'liquid ';
  _adecs : shortstring = 'adecs ';
  _tdecs : shortstring = 'tdecs ';
  _brock : shortstring = 'brocks ';
  _srock : shortstring = 'srocks ';
  _lirgb : shortstring = 'liqstl ';
  _tdstl : shortstring = 'tdecstl ';
  _terst : shortstring = 'terstl ';
  _tdeca : shortstring = 'tdecan ';
  _tsrka : shortstring = 'srockan ';
  _tbrka : shortstring = 'brockan ';

var f:text;
    s:shortstring;
    i:byte;
_ades,
_tdes,
_liqs,
_ters,
_brcs,
_srcs: set of byte;
_tname:shortstring;
inthb: boolean;

procedure _defset;
begin
   _ades:=[];
   _tdes:=[];
   _liqs:=[];
   _ters:=[];
   _brcs:=[];
   _srcs:=[];
   _tname:='';
end;

procedure endtheme;
var t:byte;
begin
   if(inthb)
   and(_ades<>[])and(_tdes<>[])and(_liqs<>[])and(_ters<>[])and(_brcs<>[])and(_srcs<>[])then
   begin
      map_themen+=1;
      setlength(map_themes,map_themen);
      with (map_themes[map_themen-1]) do
      begin
         for t:=0 to 255 do
         begin
            if(t in _ades)then begin _adecn+=1;setlength(_adecs,_adecn);_adecs[_adecn-1]:=t;end;
            if(t in _tdes)then begin _tdecn+=1;setlength(_tdecs,_tdecn);_tdecs[_tdecn-1]:=t;end;
            if(t in _liqs)then begin _liqdn+=1;setlength(_liqds,_liqdn);_liqds[_liqdn-1]:=t;end;
            if(t in _ters)then begin _terrn+=1;setlength(_terrs,_terrn);_terrs[_terrn-1]:=t;end;
            if(t in _brcs)then begin _brckn+=1;setlength(_brcks,_brckn);_brcks[_brckn-1]:=t;end;
            if(t in _srcs)then begin _srckn+=1;setlength(_srcks,_srckn);_srcks[_srckn-1]:=t;end;
         end;
         _name:=_tname;
      end;
   end;

   inthb:=true;

   _defset;
end;

begin
   map_themec:=0;
   while (map_themen>0) do
    with map_themes[map_themen] do
    begin
       _adecn:=0;setlength(_adecs,0);
       _tdecn:=0;setlength(_tdecs,0);
       _liqdn:=0;setlength(_liqds,0);
       _terrn:=0;setlength(_terrs,0);
       _brckn:=0;setlength(_brcks,0);
       _srckn:=0;setlength(_srcks,0);
       _name:='';

       map_themen-=1;
    end;
   setlength(map_themes,0);
   FillChar(map_Liquidc ,SizeOf(map_Liquidc) ,0);
   FillChar(anm_Liquids ,SizeOf(anm_Liquids) ,0);
   FillChar(ans_Liquids ,SizeOf(ans_Liquids) ,30);
   FillChar(anb_Terrain ,SizeOf(anb_Terrain) ,0);
   FillChar(ans_Terrain ,SizeOf(ans_Terrain) ,false);
   FillChar(tdecs_animn ,SizeOf(tdecs_animn) ,0);
   FillChar(tdecs_animt ,SizeOf(tdecs_animt) ,0);
   FillChar(srocks_animn,SizeOf(srocks_animn),0);
   FillChar(srocks_animt,SizeOf(srocks_animt),0);
   FillChar(brocks_animn,SizeOf(brocks_animn),0);
   FillChar(brocks_animt,SizeOf(brocks_animt),0);
   FillChar(tdecs_ys    ,SizeOf(tdecs_ys    ),0);
   for i:=0 to 255 do shd_TDecs[i]:=1;

   s:=str_folder_gr+'map\themes.txt';
   if(FileExists(s)) then
   begin
      {$I-}
      assign(f,s);
      reset(f);

      inthb:=false;
      _defset;

      while(true)do
      begin
         if(ioresult<>0)or(EOF(f))then
         begin
            endtheme;
            break;
         end;

         readln(f,s);
         if(s='stop')then break;

         if(_chstr(@s,@_theme))then begin endtheme; _tname:=insertColorChars(s);if(map_themen=255)then break; end;
         if(_chstr(@s,@_terra))then str2set(s,@_ters);
         if(_chstr(@s,@_liqui))then str2set(s,@_liqs);
         if(_chstr(@s,@_adecs))then str2set(s,@_ades);
         if(_chstr(@s,@_tdecs))then str2set(s,@_tdes);
         if(_chstr(@s,@_brock))then str2set(s,@_brcs);
         if(_chstr(@s,@_srock))then str2set(s,@_srcs);
         if(_chstr(@s,@_lirgb))then str2lrgb(s,0);
         if(_chstr(@s,@_tdstl))then str2lrgb(s,1);
         if(_chstr(@s,@_terst))then str2lrgb(s,2);
         if(_chstr(@s,@_tdeca))then str2lrgb(s,3);
         if(_chstr(@s,@_tsrka))then str2lrgb(s,4);
         if(_chstr(@s,@_tbrka))then str2lrgb(s,5);

      end;

      close(f);
      {$I+}
   end;

   if(map_themen=0)then
   begin
      map_themen+=1;
      setlength(map_themes,map_themen);
      with map_themes[map_themen-1] do
      begin
         _adecn:=CraterMR;
         setlength(_adecs,_adecn);
         for i:=0 to _adecn do _adecs[i]:=i;

         _tdecn:=1;setlength(_tdecs,_tdecn);_tdecs[0]:=0;
         _liqdn:=1;setlength(_liqds,_liqdn);_liqds[0]:=0;
         _terrn:=1;setlength(_terrs,_terrn);_terrs[0]:=0;
         _brckn:=1;setlength(_brcks,_brckn);_brcks[0]:=0;
         _srckn:=1;setlength(_srcks,_srckn);_srcks[0]:=0;

         _name:='DEFAULT';
      end;
   end;
end;

