
////////////////////////////////////////////////////////////////////////////////
//
//  MAIN
//


function UIDsArmsImpactUpgr(upgr:byte):TSoB;
var uid,arm:byte;
begin
   UIDsArmsImpactUpgr:=[];
   for uid in [1..255] do
     with g_uids[uid] do
       if(uid_r>0)then
         for arm:=0 to LastUnitArms do
           with uid_arms[arm] do
             if(aw_impact_upgr=upgr)then UIDsArmsImpactUpgr+=[uid];
end;

procedure DocHelp_AddHotKeyAction(iActSet:TSoB;descr:shortstring;gapStr:shortstring=': ');
var i:byte;
   hk:shortstring;
begin
   if(iActSet=[])
   then str_AddToUIStringList(@str_doc_HotKeys,ui_DocLineLen1,false,false,descr)
   else
   begin
      hk:='';
      for i in iActSet do
        STRADD(@hk,str_ActionHotKey(i),sep_space);
      str_AddToUIStringList(@str_doc_HotKeys,ui_DocLineLen2,false,false,hk+gapStr+descr+tc_docbr);
   end;
end;
procedure DocHelp_AddBaseControls(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_BaseControls,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddBaseMchanics(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_BaseMechanics,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddGamUI(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_GameUI,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddOther(line:shortstring);
begin
   str_AddToUIStringList(@str_doc_Other,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddCredits(line:shortstring);
begin
   if(line<>tc_docbr)then line+=tc_docbr;
   str_AddToUIStringList(@str_doc_Credits,ui_DocLineLen2,false,false,line);
end;
procedure DocHelp_AddCreditsMusic;
var Info: TSearchRec;
begin
   if(FindFirst(folder_sound+folder_music_menu+'*.ogg',faReadonly,info)=0)then
     repeat
       setlength(info.Name,length(info.Name)-4);
       DocHelp_AddCredits('- '+info.Name);
     until(FindNext(info)<>0);
   FindClose(info);
   if(FindFirst(folder_sound+folder_music_game+'*.ogg',faReadonly,info)=0)then
     repeat
       setlength(info.Name,length(info.Name)-4);
       DocHelp_AddCredits('- '+info.Name);
     until(FindNext(info)<>0);
   FindClose(info);
end;

procedure str_camp_Add(name:shortstring);
begin
   camp_size+=1;
   setlength(camp_list      ,camp_size);
   setlength(camp_mis_list  ,camp_size);
   setlength(camp_mis_size  ,camp_size);
   setlength(camp_obj_main  ,camp_size);
   setlength(camp_obj_object,camp_size);
   setlength(camp_obj_loc   ,camp_size);
   setlength(camp_obj_size  ,camp_size);

   camp_mis_size[camp_size-1]:=0;
   setlength(camp_mis_list[camp_size-1],0);
   camp_list[camp_size-1]:=name;
   setlength(camp_obj_main  [camp_size-1],0);
   setlength(camp_obj_object[camp_size-1],0);
   setlength(camp_obj_loc   [camp_size-1],0);
   setlength(camp_obj_size  [camp_size-1],0);
end;

procedure str_camp_MisAdd(camp_n:integer;name:shortstring);
begin
   if(camp_n<0)
   or(camp_size<=camp_n)then exit;

   camp_mis_size[camp_n]+=1;
   setlength(camp_mis_list  [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_main  [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_object[camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_loc   [camp_n],camp_mis_size[camp_n]);
   setlength(camp_obj_size  [camp_n],camp_mis_size[camp_n]);
   camp_obj_object[camp_n][camp_mis_size[camp_n]-1]:='';
   camp_obj_loc   [camp_n][camp_mis_size[camp_n]-1]:='';
   camp_mis_list[camp_n][camp_mis_size[camp_n]-1]:=name;

   setlength(camp_obj_main[camp_n][camp_mis_size[camp_n]-1],0);
             camp_obj_size[camp_n][camp_mis_size[camp_n]-1]:=0;
end;

procedure str_camp_MissTextAdd(camp_n,miss_n:integer;line:shortstring);
begin
   if(camp_n<0)
   or(camp_size<=camp_n)then exit;

   if(miss_n<0)
   or(camp_mis_size[camp_n]<=miss_n)then exit;

   str_AddToStringArray(@camp_obj_main[camp_n][miss_n],@camp_obj_size[camp_n][miss_n],nil,menu_infoLineSize,false,false,line);
end;

procedure str_camp_MissObjSet(camp_n,miss_n:integer;objectives,location:shortstring);
begin
   if(camp_n<0)
   or(camp_size<=camp_n)then exit;

   if(miss_n<0)
   or(camp_mis_size[camp_n]<=miss_n)then exit;

   camp_obj_object[camp_n][miss_n]:=objectives;
   camp_obj_loc   [camp_n][miss_n]:=location;
end;

procedure str_camp_clear;
begin
   while(camp_size>0)do
   begin
      camp_size-=1;

      while(camp_mis_size[camp_size]>0)do
      begin
         camp_mis_size[camp_size]-=1;
         setlength(camp_obj_main[camp_size][camp_mis_size[camp_size]],0);
      end;

      setlength(camp_mis_list  [camp_size],0);
      setlength(camp_obj_main  [camp_size],0);
      setlength(camp_obj_object[camp_size],0);
      setlength(camp_obj_loc   [camp_size],0);
   end;
   setlength(camp_list      ,camp_size);
   setlength(camp_mis_list  ,camp_size);
   setlength(camp_mis_size  ,camp_size);
   setlength(camp_obj_main  ,camp_size);
   setlength(camp_obj_size  ,camp_size);
   setlength(camp_obj_object,camp_size);
   setlength(camp_obj_loc   ,camp_size);
end;

////////////////////////////////////////////////////////////////////////////////

{$include _lang_ENG.pas}

{$include _lang_RUS.pas}

procedure SwitchLanguage;
begin
  if(ui_language)
  then lng_rus
  else lng_eng;
end;



