
const


str_htmldoc_folder   = 'docs';
str_htmldoc_imgsGame = 'imgs\';
str_htmldoc_unitFront= str_htmldoc_imgsGame+'unitFront';
str_htmldoc_unitBTN  = str_htmldoc_imgsGame+'unitBTN';
str_htmldoc_upgrBTN  = str_htmldoc_imgsGame+'upgrBTN';
str_htmldoc_img_ext  = '.bmp';
str_htmldoc_fname    = str_htmldoc_folder+'\MarsWars_';
str_htmldoc_ext      = '.html';

str_htmldoc_back1    = '../graphic/map/terrains/ter3.png';
str_htmldoc_back2    = '../graphic/map/terrains/ter11.png';

var

html_f  :text;

procedure htmldoc_sdlsurf(fname:shortstring;sdlsurf:pSDL_Surface);
begin
   if(sdlsurf=nil)then exit;
   if(FileExists(fname))then exit;
   fname:=fname+#0;
   if(sdl_saveBMP(sdlsurf,@fname[1])<=0)then writeln(sdl_getError);
end;

function htmldoc_UID1Spr(uid:byte):boolean;
begin
   with g_uids[uid] do
     htmldoc_UID1Spr:=uid_SpriteModel[0]=uid_SpriteModel[LastUnitLevel];
end;

function htmldoc_UIDImg(uid:byte):shortstring;
var  l:byte;
titels:shortstring;
begin
   with g_uids[uid] do titels:=' title="'+uid_str_name+'"';
   if(htmldoc_UID1Spr(uid))
   then htmldoc_UIDImg:='<img src="'+str_htmldoc_unitFront+b2s(uid)+str_htmldoc_img_ext+'"'+titels+'>'
   else
   begin
      htmldoc_UIDImg:='';
      for l:=0 to LastUnitLevel do
      begin
         if(length(htmldoc_UIDImg)>0)then htmldoc_UIDImg+=' ';
         htmldoc_UIDImg+='<img src="'+str_htmldoc_unitFront+b2s(uid)+'_'+b2s(l)+str_htmldoc_img_ext+'"'+titels+'>';
         if(l=1)then
           htmldoc_UIDImg+='<br>';
      end;
   end;
end;
function htmldoc_UIDBTN(uid:byte):shortstring;
begin
   htmldoc_UIDBTN :='<img style="border:1px solid #666666" src="'+str_htmldoc_unitBTN+b2s(uid)+str_htmldoc_img_ext+'" title="'+g_uids [uid].uid_str_name +'">';
end;
function htmldoc_UpgrBTN(uid:byte):shortstring;
begin
   htmldoc_UpgrBTN:='<img style="border:1px solid #666666" src="'+str_htmldoc_upgrBTN+b2s(uid)+str_htmldoc_img_ext+'" title="'+g_upgrs[uid].upgr_str_name+'">';
end;

function htmldoc_color2hex(color:TMWColor):shortstring;
begin
   htmldoc_color2hex:=HexStr((color and $FF000000)shr 24,2)+
                      HexStr((color and $00FF0000)shr 16,2)+
                      HexStr((color and $0000FF00)shr 8 ,2);
end;

procedure htmldoc_WriteCaption(line:shortstring);
begin
   writeln(html_f,'<br><center><h2 id="'+line+'"><b>',line,'</b></h2></center><br>');
end;

var capt_link : byte = 1;
procedure htmldoc_WriteLinkToCapt(line:shortstring);
begin
   writeln(html_f,'<a href="#'+line+'"><u><b>',capt_link,'. ',line,'</b></u></a><br>');
   capt_link+=1;
end;

procedure htmldoc_WriteLine(line:shortstring);
var
i,l  :byte;
c    :char;
tag_b,
tag_m,
tag_c:boolean;
procedure TagColor(c:TMWColor);
begin
   if(tag_c)then write(html_f,'</font>');
   write(html_f,'<font color="'+htmldoc_color2hex(c)+'">');
   tag_c:=true;
end;
begin
   l:=length(line);
   if(l=0)then exit;
   //tstr :='';
   tag_b:=false;
   tag_c:=false;
   tag_m:=false;
   if(pos(tc_doccnt,line)>0)then
   begin
      tag_m:=true;
      write(html_f,'<center>');
   end;
   if(pos(tc_doccpt,line)>0)then
   begin
      tag_b:=true;
      write(html_f,'<b>');
   end;
   for i:=1 to l do
   begin
      c:=line[i];
      case c of
      tc_docbr    : write(html_f,'<br>');
      tc_doccpt   : ;
      tc_player0..
      tc_player7  : TagColor(PlayerGetColorDef(ord(c)));
      tc_nl1,
      tc_nl2,
      tc_nl3      :;
      tc_default  : begin
                    if(tag_c)then write(html_f,'</font>');
                    tag_c:=false;
                    end;

      tc_purple   : TagColor(c_purple);
      tc_red      : TagColor(c_red   );
      tc_orange   : TagColor(c_orange);
      tc_yellow   : TagColor(c_yellow);
      tc_lime     : TagColor(c_lime  );
      tc_aqua     : TagColor(c_aqua  );
      tc_blue     : TagColor(c_blue  );
      tc_gray     : TagColor(c_gray  );
      tc_white    : TagColor(c_white );
      tc_green    : TagColor(c_green );
      tc_dgray    : TagColor(c_dgray );
      else write(html_f,c);
      end;
   end;
   if(tag_c)then write(html_f,'</font>'  );
   if(tag_b)then write(html_f,'</b>'     );
   if(tag_m)then write(html_f,'</center>');
   writeln(html_f);
end;

procedure htmldoc_WriteStringArray(plist:PTStringArray;listSize:integer);
var i:integer;
begin
   if(listSize>0)then
     for i:=0 to listSize-1 do
       htmldoc_WriteLine(plist^[i]);
end;

procedure htmldoc_SaveSprites;
var
uid,i:byte;
begin
   for uid:=0 to 255 do
   begin
      with g_uids[uid] do
        if(uid_r>0)then
        begin
           if(htmldoc_UID1Spr(uid))
           then htmldoc_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_unitFront+b2s(uid)+str_htmldoc_img_ext,gfx_uid2spr(uid,270,0)^.surf )
           else
             for i:=0 to LastUnitLevel do
               htmldoc_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_unitFront+b2s(uid)+'_'+b2s(i)+str_htmldoc_img_ext,gfx_uid2spr(uid,270,i)^.surf );

           htmldoc_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_unitBTN  +b2s(uid)+str_htmldoc_img_ext,uid_BTNDoc.surf );
        end;
      with g_upgrs[uid] do
        if(upgr_max>0)then
          htmldoc_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_upgrBTN  +b2s(uid)+str_htmldoc_img_ext,upgr_btnBig.surf );
   end;
end;

procedure htmldoc_make;
var
uid,i:byte;
begin
   assign(html_f,str_htmldoc_fname+str_SG_LanguageL[ui_language]+str_htmldoc_ext);
{$I-}rewrite(html_f);{$I+}
   if(ioresult<>0)then exit;

   writeln(html_f,'<html><head><meta charset="utf-8"><title>');
   writeln(html_f,str_gcaption);
   writeln(html_f,'</title></head>');
   writeln(html_f,'<body text="#ffffff" bgcolor="#220000" link="#ffffff" alink="#666666" vlink="#AAAAAA" background="'+str_htmldoc_back1+'">');
   writeln(html_f,'<div align="center"><table bgcolor="#000000" width="1000" border="1" bordercolor="#ffffff" background="'+str_htmldoc_back2+'">');
   writeln(html_f,'<tr><td align="center" ><b><font size="66" color="#D8893A">'+str_gcaption+'</font></b></td></tr>');
   writeln(html_f,'<tr><td align="left">');

   /////////////////////////////////////////////////////////////////////////////
   //  CONTENTS
   htmldoc_WriteLinkToCapt(str_help_Credits);
   htmldoc_WriteLinkToCapt(str_help_GameControls);
   htmldoc_WriteLinkToCapt(str_help_GameHotKeys);
   htmldoc_WriteLinkToCapt(str_help_GameUI);
   htmldoc_WriteLinkToCapt(str_help_GameMechanics);
   htmldoc_WriteLinkToCapt(str_help_UnitsInfo);
   htmldoc_WriteLinkToCapt(str_help_BalanceTable);
   htmldoc_WriteLinkToCapt(str_help_UpgradesInfo);
   htmldoc_WriteLinkToCapt(str_help_Other);

   /////////////////////////////////////////////////////////////////////////////
   //  CREDITS
   htmldoc_WriteCaption(str_help_Credits);
   with str_doc_Credits do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  GAME BASICS CONTROLS
   htmldoc_WriteCaption(str_help_GameControls);
   with str_doc_BaseControls do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  GAME HOTKEYS
   htmldoc_WriteCaption(str_help_GameHotKeys);
   with str_doc_HotKeys do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  GAME UI
   htmldoc_WriteCaption(str_help_GameUI);
   writeln(html_f,'<center><img style="border:1px solid #BBBBBB" src="..\graphic\doc_ui.png" title="'+str_help_ImgUI      +'"><br>'+str_help_ImgUI      ,'<br><br>');
   writeln(html_f,        '<img style="border:1px solid #BBBBBB" src="..\graphic\doc_upgrades.png" title="'+str_help_ImgUUpgrade+'"><br>'+str_help_ImgUUpgrade+'</center>');
   with str_doc_GameUI do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  GAME MECHANICS
   htmldoc_WriteCaption(str_help_GameMechanics);
   writeln(html_f,'<center><img style="border:1px solid #BBBBBB" src="..\graphic\doc_Generators.png" title="',str_help_ImgGenerators,'"><br>',str_help_ImgGenerators,'<br><br>');
   writeln(html_f,        '<img style="border:1px solid #BBBBBB" src="..\graphic\doc_KeyPoint.png" title="'  ,str_help_ImgKeyPoints ,'"><br>',str_help_ImgKeyPoints ,'<br><br>');
   writeln(html_f,        '<img style="border:1px solid #BBBBBB" src="..\graphic\doc_koth.png" title="'      ,str_help_ImgKotH      ,'"><br>',str_help_ImgKotH      ,'</center>');
   with str_doc_BaseMechanics do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  UNITS INFO
   htmldoc_WriteCaption(str_help_UnitsInfo);
   writeln(html_f,'<center><table bgcolor="#000000" width="900" border="1" bordercolor="#ffffff">');
   for uid:=0 to 255 do
     with g_uids[uid] do
       if(uid_r>0)then
       begin
           writeln(html_f,'<tr><td align="center">');
           //writeln(html_f,'<b>',uid_str_name,'</b><br><br>');
           writeln(html_f,htmldoc_UIDImg(uid));
           writeln(html_f,'</td><td>');

           writeln(html_f,'<center><b>',uid_str_name,'</b></center>');
           with uid_HintDoc do
           htmldoc_WriteStringArray(@slist_l,slist_n);

           writeln(html_f,'</td></tr>');
        end;
   writeln(html_f,'</table></center>');

   /////////////////////////////////////////////////////////////////////////////
   //  BALANCE TABLE
   htmldoc_WriteCaption(str_help_BalanceTable);
   writeln(html_f,str_doc_NoteUnitBalance,'<br>');
   writeln(html_f,'<center><table bgcolor="#000000" width="900" border="1" bordercolor="#ffffff">');
   for uid:=0 to 255 do
     with g_uids[uid] do
       if(menudoc_ValidForTableUnit(uid,true))then
       begin
          writeln(html_f,'<tr><td align="center" style="width: 100px;">');
          //writeln(html_f,'<b>',uid_str_name,'</b><br><br>');
          writeln(html_f,htmldoc_UIDBTN(uid));
          writeln(html_f,'</td><td>');

          writeln(html_f,'<center><b>',uid_str_name,'</b></center>');

          htmldoc_WriteLine(str_doc_BalanceGood);   writeln(html_f,'<br>');
          for i in uid_balance_Good do writeln(html_f,htmldoc_UIDBTN(i));
          if(length(uid_str_balance_Good)>0)then begin writeln(html_f,'<br>');htmldoc_WriteLine(uid_str_balance_Good);end;
          writeln(html_f,'<br><br>');

          htmldoc_WriteLine(str_doc_BalanceBad);    writeln(html_f,'<br>');
          for i in uid_balance_Bad do writeln(html_f,htmldoc_UIDBTN(i));
          if(length(uid_str_balance_Bad)>0)then begin writeln(html_f,'<br>');htmldoc_WriteLine(uid_str_balance_Bad);end;
          writeln(html_f,'<br><br>');

          htmldoc_WriteLine(str_doc_BalanceUseless);writeln(html_f,'<br>');
          for i in uid_balance_Useless do writeln(html_f,htmldoc_UIDBTN(i));
          if(length(uid_str_balance_Useless)>0)then begin writeln(html_f,'<br>');htmldoc_WriteLine(uid_str_balance_Useless);end;
          writeln(html_f,'<br><br>');

          writeln(html_f,'</td></tr>');
       end;
   writeln(html_f,'</table></center>');

   /////////////////////////////////////////////////////////////////////////////
   //  UPGRADES INFO
   htmldoc_WriteCaption(str_help_UpgradesInfo);
   writeln(html_f,'<center><table bgcolor="#000000" width="900" border="1" bordercolor="#ffffff">');
   for uid:=0 to 255 do
     with g_upgrs[uid] do
       if(upgr_max>0)then
       begin
           writeln(html_f,'<tr><td align="center" style="width: 100px;">');
           writeln(html_f,htmldoc_UpgrBTN(uid));
           writeln(html_f,'</td><td>');

           writeln(html_f,'<center><b>',upgr_str_name,'</b></center>');
           with upgr_HintDoc do
           htmldoc_WriteStringArray(@slist_l,slist_n);

           writeln(html_f,'</td></tr>');
        end;
   writeln(html_f,'</table></center>');

   /////////////////////////////////////////////////////////////////////////////
   //  OTHER
   htmldoc_WriteCaption(str_help_Other);
   with str_doc_Other do
   htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////
   writeln(html_f,'</td></tr></table></div></html>');
   close(html_f);
end;




