
const


str_htmldoc_folder   = 'docs';
str_htmldoc_imgs     = 'imgs\';
str_htmldoc_img_ext  = '.bmp';
str_htmldoc_fname    = str_htmldoc_folder+'\index.html';

var

html_f  :text;

procedure save_sdlsurf(fname:shortstring;sdlsurf:pSDL_Surface);
begin
   if(sdlsurf=nil)then exit;
   if(FileExists(fname))then exit;
   fname:=fname+#0;
   if(sdl_saveBMP(sdlsurf,@fname[1])<=0)then writeln(sdl_getError);
end;

procedure htmldoc_WriteCaption(line:shortstring);
begin
   writeln(html_f,'<br><center><h2><b>',line,'</b></h2></center><br>');
end;

procedure htmldoc_WriteLine(line:shortstring);
var i,l:byte;
begin
   l:=length(line);
   if(l=0)then exit;
   for i:=1 to l do
     if(line[i]<>tc_docbr)
     then break
     else
     begin
        writeln(html_f,'<br>');
        if(i=l)then exit;
     end;
   if(pos(tc_doccpt,line)>0)then line:='<b>'+line+'</b>';
   writeln(html_f,str_RemoveSpecChars(line,false),' ');
   for i:=l downto 1 do
     if(line[i]<>tc_docbr)
     then break
     else writeln(html_f,'<br>');
end;

procedure htmldoc_WriteStringArray(plist:PTStringArray;listSize:integer);
var i:integer;
begin
   if(listSize>0)then
     for i:=0 to listSize-1 do
       htmldoc_WriteLine(plist^[i]);
end;

procedure htmldoc_make;
var
uid,i:byte;
begin
   assign(html_f,str_htmldoc_fname);
{$I-}rewrite(html_f);{$I+}
   if(ioresult<>0)then exit;

   writeln(html_f,'<html><head><meta charset="utf-8"><title>');
   writeln(html_f,str_gcaption);
   writeln(html_f,'</title></head>');
   writeln(html_f,'<body text="#ffffff" bgcolor="#220000" link="#ffffff" alink="#666666" vlink="#AAAAAA" background="../graphic/map/terrains/ter3.png">');
   writeln(html_f,'<div align="center"><table bgcolor="#000000" width="1000" border="1" bordercolor="#ffffff" background="../graphic/map/terrains/ter11.png">');
   writeln(html_f,'<tr><td align="center" ><b><font size="66" color="#D8893A">'+str_gcaption+'</font></b></td></tr>');
   writeln(html_f,'<tr><td align="left">');

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
   //with str_doc_HotKeys do
   //htmldoc_WriteStringArray(@slist_l,slist_n);

   /////////////////////////////////////////////////////////////////////////////
   //  GAME BASICS CONTROLS

   htmldoc_WriteCaption(str_help_GameMechanics);
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
           writeln(html_f,'<img src="'+str_htmldoc_imgs+'unitFront'+b2s(uid)+str_htmldoc_img_ext+'">');
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
   writeln(html_f,str_doc_unitBalanceNote,'<br>');
   writeln(html_f,'<center><table bgcolor="#000000" width="900" border="1" bordercolor="#ffffff">');
   for uid:=0 to 255 do
     with g_uids[uid] do
       if(IsUIDValidForHelpTable(uid,true))then
       begin
          writeln(html_f,'<tr><td align="center">');
          writeln(html_f,uid_str_name,'<br>');
          writeln(html_f,'<img src="'+str_htmldoc_imgs+'unitBTN'+b2s(uid)+str_htmldoc_img_ext+'">');
          writeln(html_f,'</td><td>');

          writeln(html_f,str_doc_BalanceGood   ,'<br>');
          for i in uid_balance_Good do writeln(html_f,'<img src="'+str_htmldoc_imgs+'unitBTN'+b2s(i)+str_htmldoc_img_ext+'">');
          writeln(html_f,'<br><br>');

          writeln(html_f,str_doc_BalanceBad    ,'<br>');
          for i in uid_balance_Bad do writeln(html_f,'<img src="'+str_htmldoc_imgs+'unitBTN'+b2s(i)+str_htmldoc_img_ext+'">');
          writeln(html_f,'<br><br>');

          writeln(html_f,str_doc_BalanceUseless,'<br>');
          for i in uid_balance_Useless do writeln(html_f,'<img src="'+str_htmldoc_imgs+'unitBTN'+b2s(i)+str_htmldoc_img_ext+'">');
          writeln(html_f,'<br><br>');

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

   // save sprites
   for uid:=0 to 255 do
     with g_uids[uid] do
       if(uid_r>0)then
        begin
           save_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_imgs+'unitFront'+b2s(uid)+str_htmldoc_img_ext,gfx_uid2spr(uid,270,0)^.surf );
           save_sdlsurf(str_htmldoc_folder+'\'+str_htmldoc_imgs+'unitBTN'  +b2s(uid)+str_htmldoc_img_ext,uid_BTNDoc.surf );
        end;
end;




