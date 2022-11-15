
function l2s(limit:integer):shortstring; // limit 2 string
var fr:integer;
begin
   fr:=limit mod MinUnitLimit;
   case fr of
   0  : l2s:=i2s(limit div MinUnitLimit);
   50 : l2s:=i2s(limit div MinUnitLimit)+'.5';
   25 : l2s:=i2s(limit div MinUnitLimit)+'.25';
   else l2s:=i2s(limit div MinUnitLimit)+'.'+i2s(fr);
   end;
end;

function GetKeyName(k:cardinal):shortstring;
begin
   case k of
SDL_BUTTON_left     : GetKeyName:='Mouse left button';
SDL_BUTTON_right    : GetKeyName:='Mouse right button';
SDL_BUTTON_middle   : GetKeyName:='Mouse middle button';
SDL_BUTTON_WHEELUP  : GetKeyName:='Mouse wheel up';
SDL_BUTTON_WHEELDOWN: GetKeyName:='Mouse wheel down';
SDLK_LCtrl,
SDLK_RCtrl          : GetKeyName:='Ctrl';
SDLK_LAlt,
SDLK_RAlt           : GetKeyName:='Alt';
SDLK_LShift,
SDLK_RShift         : GetKeyName:='Shift';
   else GetKeyName  :=UpperCase(SDL_GetKeyName(k));
   end
end;



function _gHK(ucl:byte):shortstring;  // hotkey units&upgrades tab
begin
   _gHK:='';
   if(ucl<=_mhkeys)then
    if(_hotkey1[ucl]>0)then
    begin
       if(_hotkey2[ucl]>0)then
       _gHK:=     tc_lime+GetKeyName(_hotkey2[ucl])+tc_default+'+';
       _gHK:=_gHK+tc_lime+GetKeyName(_hotkey1[ucl])+tc_default;
    end;
end;

function _gHKA(ucl:byte):shortstring;  // hotkey actions tab
begin
   _gHKA:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyA[ucl]>0)then
    begin
       if(_hotkeyA2[ucl]>0)then
       _gHKA:=      tc_lime+GetKeyName(_hotkeyA2[ucl])+tc_default+'+';
       _gHKA:=_gHKA+tc_lime+GetKeyName(_hotkeyA [ucl])+tc_default;
    end;
end;
function _gHKR(ucl:byte):shortstring;  // hotkey replays tab
begin
   _gHKR:='';
   if(ucl<=_mhkeys)then
    if(_hotkeyR[ucl]>0)then
    begin
       if(_hotkeyR2[ucl]>0)then
       _gHKR:=      tc_lime+GetKeyName(_hotkeyR2[ucl])+tc_default+'+';
       _gHKR:=_gHKR+tc_lime+GetKeyName(_hotkeyR [ucl])+tc_default;
    end;
end;

procedure _mkHStrACT(ucl:byte;hint:shortstring);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      hk:=_gHKA(ucl);
      if(length(hk)>0)
      then str_hint_a[ucl]:=hint+' ('+hk+')'
      else str_hint_a[ucl]:=hint;
   end;
end;

procedure _mkHStrREQ(ucl:byte;hint:shortstring;noHK:boolean);
var hk:shortstring;
begin
   if(ucl<=_mhkeys)then
   begin
      if(noHK)
      then hk:=''
      else hk:=_gHKR(ucl);
      if(length(hk)>0)
      then str_hint_r[ucl]:=hint+' ('+hk+')'
      else str_hint_r[ucl]:=hint;
   end;
end;

procedure _mkHStrUid(uid:byte;NAME,DESCR:shortstring);
begin
   with _uids[uid] do
   begin
      un_txt_name :=NAME;
      un_txt_descr:=DESCR;
   end;
end;

procedure _mkHStrUpid(upid:byte;NAME,DESCR:shortstring);
begin
   with _upids[upid] do
   begin
      _up_name :=NAME;
      _up_descr:=DESCR;
   end;
end;

procedure _ADDSTRC(s:pshortstring;ad:shortstring);
begin
   if(length(s^)=0)
   then s^:=ad
   else s^:=s^+',' +ad;
end;
procedure _ADDSTRS(s:pshortstring;ad:shortstring);
begin
   if(length(s^)=0)
   then s^:=ad
   else s^:=s^+'/' +ad;
end;


function findprd(uid:byte):shortstring;
var i:byte;
   up,
   bp: shortstring;
begin
   up:='';
   bp:='';
   findprd:='';
   for i:=0 to 255 do
   begin
      if(uid in _uids[i].ups_units  )then _ADDSTRC(@up,_uids[i].un_txt_name);
      if(uid in _uids[i].ups_builder)then _ADDSTRC(@bp,_uids[i].un_txt_name);
   end;

   if(length(up)>0)then _ADDSTRC(@findprd,up);
   if(length(bp)>0)then _ADDSTRC(@findprd,bp);
end;

function _makeAttributeStr(pu:PTUnit;auid:byte):shortstring;
begin
   if(pu=nil)then
   begin
      pu:=@_units[0];
      with pu^ do
      begin
         uidi:=auid;
         playeri:=0;
         player :=@_players[playeri];
      end;
      _unit_apUID(pu);
   end;
   with pu^  do
   with uid^ do
   begin
      if(_ukbuilding)
      then _makeAttributeStr:=str_attr_building
      else _makeAttributeStr:=str_attr_unit;
      if(_ukmech)
      then _ADDSTRC(@_makeAttributeStr,str_attr_mech)
      else _ADDSTRC(@_makeAttributeStr,str_attr_bio );
      if(_uklight)
      then _ADDSTRC(@_makeAttributeStr,str_attr_light )
      else _ADDSTRC(@_makeAttributeStr,str_attr_nlight);
      if(ukfly)
      then _ADDSTRC(@_makeAttributeStr,str_attr_fly)
      else
        if(ukfloater)
        then _ADDSTRC(@_makeAttributeStr,str_attr_floater)
        else _ADDSTRC(@_makeAttributeStr,str_attr_ground );
      if(level>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_level+b2s(level+1));
      if(buff[ub_detect]>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_detector);
      if(buff[ub_invuln]>0)
      then _ADDSTRC(@_makeAttributeStr,str_attr_invuln)
      else
        if(buff[ub_stun]>0)or(buff[ub_pain]>0)
        then _ADDSTRC(@_makeAttributeStr,str_attr_stuned);

      _makeAttributeStr:='['+_makeAttributeStr+']';
   end;
end;
function _makeDynUnitHint(pu:PTUnit):shortstring;
begin
   with pu^  do
    with uid^ do
     _makeDynUnitHint:=un_txt_name+' ('+pu^.player^.name+')'+tc_nl1+_makeAttributeStr(pu,0)+tc_nl1+un_txt_descr;
end;

procedure _makeHints;
var
uid,l       :byte;
ENRG,HK,PROD,LMT,INFO,
TIME,REQ    :shortstring;
begin
   // units
   for uid:=0 to 255 do
   with _uids[uid] do
   begin
      REQ :='';
      PROD:='';
      ENRG:='';
      TIME:='';
      LMT :='';
      INFO:='';

      if(_ucl>=23)then
      begin
         un_txt_uihint:=un_txt_name+tc_nl1+un_txt_descr+tc_nl1;
      end
      else
      begin
         HK:=_gHK(_ucl);
         if(_renergy>0)then ENRG:=tc_aqua +i2s(_renergy)+tc_default;
         if(_btime  >0)then TIME:=tc_white+i2s(_btime  )+tc_default;
         LMT:=tc_orange+l2s(_limituse)+tc_default;

         PROD:=findprd(uid);
         if(_ruid1>0)then if(_ruid1n<=1)then _ADDSTRC(@REQ,_uids [_ruid1].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid1].un_txt_name+'(x'+b2s(_ruid1n)+')');
         if(_ruid2>0)then if(_ruid2n<=1)then _ADDSTRC(@REQ,_uids [_ruid2].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid2].un_txt_name+'(x'+b2s(_ruid2n)+')');
         if(_ruid3>0)then if(_ruid3n<=1)then _ADDSTRC(@REQ,_uids [_ruid3].un_txt_name) else _ADDSTRC(@REQ,_uids [_ruid3].un_txt_name+'(x'+b2s(_ruid3n)+')');
         if(_rupgr>0)then if(_rupgrn<=1)then _ADDSTRC(@REQ,_upids[_rupgr]._up_name   ) else _ADDSTRC(@REQ,_upids[_rupgr]._up_name   +'(x'+b2s(_rupgrn)+')');

         if(length(HK  )>0)then _ADDSTRC(@INFO,HK  );
         if(length(ENRG)>0)then _ADDSTRC(@INFO,ENRG);
         if(length(LMT )>0)then _ADDSTRC(@INFO,LMT );
         if(length(TIME)>0)then _ADDSTRC(@INFO,TIME);

         un_txt_uihint:=un_txt_name+' ('+INFO+')'+tc_nl1+_makeAttributeStr(nil,uid)+tc_nl1+un_txt_descr+tc_nl1;
         if(length(REQ )>0)then un_txt_uihint+=tc_yellow+str_req+tc_default+REQ+tc_nl1 else un_txt_uihint+=tc_nl1;
         if(length(PROD)>0)then
          if(_ukbuilding)
          then un_txt_uihint+=str_bprod+PROD
          else un_txt_uihint+=str_uprod+PROD;
      end;
   end;

   // upgrades
   for uid:=0 to 255 do
   with _upids[uid] do
   begin
      REQ  :='';
      PROD :='';
      ENRG :='';
      TIME :='';
      INFO :='';

      HK:=_gHK(_up_btni);
      if(_up_renerg>0)then
      begin
         if(_up_max>1)and(not _up_mfrg)
         then for l:=1 to _up_max do _ADDSTRS(@ENRG,i2s(_upid_energy(uid,l)))
         else ENRG:=i2s(_upid_energy(uid,1));
         ENRG:=tc_aqua+ENRG+tc_default;
      end;
      if(_up_time  >0)then
      begin
         if(_up_max>1)and(not _up_mfrg)
         then for l:=1 to _up_max do _ADDSTRS(@TIME,i2s(_upid_time(uid,l) div fr_fps))
         else TIME :=i2s(_upid_time(uid,1) div fr_fps);
         TIME:=tc_white+TIME+tc_default;
      end;

      if(_up_ruid  >0)then _ADDSTRC(@REQ,_uids [_up_ruid ].un_txt_name);
      if(_up_rupgr >0)then _ADDSTRC(@REQ,_upids[_up_rupgr]._up_name   );

      if(length(HK  )>0)then _ADDSTRC(@INFO,HK  );
      if(length(ENRG)>0)then _ADDSTRC(@INFO,ENRG);
      if(length(TIME)>0)then _ADDSTRC(@INFO,TIME);
      _ADDSTRC(@INFO,tc_orange+'x'+i2s(_up_max)+tc_default);
      if(_up_mfrg)then _ADDSTRC(@INFO,tc_red+'*'+tc_default);

      _up_hint:=_up_name+' ('+INFO+')'+tc_nl1+_up_descr+tc_nl1;
      if(length(REQ)>0)then _up_hint+=tc_yellow+str_req+tc_default+REQ;
   end;
end;

procedure lng_eng;
var t: shortstring;
begin
   str_MMap              := 'MAP';
   str_MPlayers          := 'PLAYERS';
   str_MObjectives       := 'OBJECTIVES';
   str_menu_s1[ms1_sett] := 'SETTINGS';
   str_menu_s1[ms1_svld] := 'SAVE/LOAD';
   str_menu_s1[ms1_reps] := 'REPLAYS';
   str_menu_s2[ms2_camp] := 'CAMPAIGNS';
   str_menu_s2[ms2_scir] := 'SKIRMISH';
   str_menu_s2[ms2_mult] := 'MULTIPLAYER';
   str_menu_s3[ms3_game] := 'GAME';
   str_menu_s3[ms3_vido] := 'VIDEO';
   str_menu_s3[ms3_sond] := 'SOUND';
   str_reset[false]      := 'START';
   str_reset[true ]      := 'RESET';
   str_exit[false]       := 'EXIT';
   str_exit[true]        := 'BACK';
   str_m_liq             := 'Lakes: ';
   str_m_siz             := 'Size: ';
   str_m_obs             := 'Obstacles: ';
   str_m_sym             := 'Symmetric: ';
   str_map               := 'Map';
   str_players           := 'Players';
   str_mrandom           := 'Random map';
   str_musicvol          := 'Music volume';
   str_soundvol          := 'Sound volume';
   str_scrollspd         := 'Scroll speed';
   str_mousescrl         := 'Mouse scroll:';
   str_fullscreen        := 'Windowed:';
   str_plname            := 'Player name';
   str_lng[true]         := 'RUS';
   str_lng[false]        := 'ENG';
   str_maction           := 'Right click action';
   str_maction2[true ]   := tc_lime  +'move'  +tc_default;
   str_maction2[false]   := tc_lime  +'move'  +tc_default+'+'+tc_red+'attack'+tc_default;
   str_race[r_random]    := tc_white +'RANDOM'+tc_default;
   str_race[r_hell  ]    := tc_orange+'HELL'  +tc_default;
   str_race[r_uac   ]    := tc_lime  +'UAC'   +tc_default;
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_gsunknown         := 'Unknown status!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_save              := 'Save';
   str_load              := 'Load';
   str_delete            := 'Delete';
   str_svld_errors[1]    := 'File not'+tc_nl3+'exists!';
   str_svld_errors[2]    := 'Can`t open'+tc_nl3+'file!';
   str_svld_errors[3]    := 'Wrong file'+tc_nl3+'size!';
   str_svld_errors[4]    := 'Wrong version!';
   str_time              := 'Time: ';
   str_menu              := 'Menu';
   str_player_def        := ' was terminated!';
   str_inv_time          := 'Wave #';
   str_inv_ml            := 'Monsters: ';
   str_play              := 'Play';
   str_replay            := 'RECORD';
   str_cmpdif            := 'Difficulty: ';
   str_waitsv            := 'Awaiting server...';
   str_goptions          := 'GAME OPTIONS';
   str_server            := 'SERVER';
   str_client            := 'CLIENT';
   str_chat              := 'CHAT';
   str_randoms           := 'Random skirmish';
   str_apply             := 'apply';
   str_plout             := ' left the game';
   str_aislots           := 'Fill empty slots:';
   str_chattars          := 'Messaging to';
   str_resol             := 'Resolution';
   str_language          := 'UI language';
   str_req               := 'Requirements: ';
   str_orders            := 'Unit groups: ';
   str_all               := 'All';
   str_uprod             := tc_lime+'Produced by: '   +tc_default;
   str_bprod             := tc_lime+'Constructed by: '+tc_default;
   str_cant_build        := 'Can`t build here!';
   str_need_energy       := 'Need more energy!';
   str_cant_prod         := 'Can`t production this!';
   str_check_reqs        := 'Check requirements!';

   str_advanced          := 'Advanced ';
   str_unit_advanced     := 'Unit promoted';
   str_upgrade_complete  := 'Upgrade complete';
   str_building_complete := 'Construction complete';
   str_unit_complete     := 'Unit ready';
   str_unit_attacked     := 'Unit is under attack';
   str_base_attacked     := 'Base is under attack';

   str_attr_unit         := tc_gray  +'unit'        +tc_default;
   str_attr_building     := tc_red   +'building'    +tc_default;
   str_attr_mech         := tc_blue  +'mechanical'  +tc_default;
   str_attr_bio          := tc_orange+'biological'  +tc_default;
   str_attr_light        := tc_yellow+'light'       +tc_default;
   str_attr_nlight       := tc_green +'heavy'       +tc_default;
   str_attr_fly          := tc_white +'flying'      +tc_default;
   str_attr_ground       := tc_lime  +'ground'      +tc_default;
   str_attr_floater      := tc_aqua  +'floater'     +tc_default;
   str_attr_level        := tc_white +'level'       ;
   str_attr_invuln       := tc_lime  +'invulnerable'+tc_default;
   str_attr_stuned       := tc_yellow+'stuned'      +tc_default;
   str_attr_detector     := tc_purple+'detector'    +tc_default;

   str_panelpos          := 'Control panel position';
   str_panelposp[0]      := tc_lime  +'left' +tc_default;
   str_panelposp[1]      := tc_orange+'right'+tc_default;
   str_panelposp[2]      := tc_yellow+'up'   +tc_default;
   str_panelposp[3]      := tc_aqua  +'down' +tc_default;

   str_uhbar             := 'Health bars';
   str_uhbars[0]         := tc_lime  +'selected'+tc_default+'+'+tc_red+'damaged'+tc_default;
   str_uhbars[1]         := tc_aqua  +'always'  +tc_default;
   str_uhbars[2]         := tc_orange+'only '   +tc_lime+'selected'+tc_default;

   str_pcolor            := 'Players colors';
   str_pcolors[0]        := tc_white +'default'+tc_default;
   str_pcolors[1]        := tc_lime  +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[2]        := tc_white +'own '   +tc_yellow+'ally '+tc_red+'enemy'+tc_default;
   str_pcolors[3]        := tc_purple+'teams'  +tc_default;
   str_pcolors[4]        := tc_white +'own '   +tc_purple+'teams'+tc_default;

   str_starta            := 'Builders at game start:';

   str_sstarts           := 'Show player starts:';

   str_pnua[0]           := tc_aqua  +'x1 '+tc_default+'/'+tc_red+' x1';
   str_pnua[1]           := tc_aqua  +'x2 '+tc_default+'/'+tc_red+' x2';
   str_pnua[2]           := tc_lime  +'x3 '+tc_default+'/'+tc_orange+' x3';
   str_pnua[3]           := tc_lime  +'x4 '+tc_default+'/'+tc_orange+' x4';
   str_pnua[4]           := tc_yellow+'x5 '+tc_default+'/'+tc_yellow+' x5';
   str_pnua[5]           := tc_yellow+'x6 '+tc_default+'/'+tc_yellow+' x6';
   str_pnua[6]           := tc_orange+'x7 '+tc_default+'/'+tc_lime+' x7';
   str_pnua[7]           := tc_orange+'x8 '+tc_default+'/'+tc_lime+' x8';
   str_pnua[8]           := tc_red   +'x9 '+tc_default+'/'+tc_aqua+' x9';
   str_pnua[9]           := tc_red   +'x10'+tc_default+'/'+tc_aqua+' x10';

   str_npnua[0]          := tc_red+'x1 ';
   str_npnua[1]          := tc_red+'x2 ';
   str_npnua[2]          := tc_orange+'x3 ';
   str_npnua[3]          := tc_orange+'x4 ';
   str_npnua[4]          := tc_yellow+'x5 ';
   str_npnua[5]          := tc_yellow+'x6 ';
   str_npnua[6]          := tc_lime+'x7 ';
   str_npnua[7]          := tc_lime+'x8 ';
   str_npnua[8]          := tc_aqua+'x9 ';
   str_npnua[9]          := tc_aqua+'x10';

   str_cmpd[0]           := tc_blue  +'I`m too young to die'+tc_default;
   str_cmpd[1]           := tc_aqua  +'Hey, not too rough'  +tc_default;
   str_cmpd[2]           := tc_lime  +'Hurt me plenty'      +tc_default;
   str_cmpd[3]           := tc_yellow+'Ultra-Violence'      +tc_default;
   str_cmpd[4]           := tc_orange+'Unholy massacre'     +tc_default;
   str_cmpd[5]           := tc_red   +'Nightmare'           +tc_default;
   str_cmpd[6]           := tc_purple+'HELL'                +tc_default;

   str_gmodet            := 'Game mode:';
   str_gmode[gm_scirmish]:= tc_lime  +'Skirmish'        +tc_default;
   str_gmode[gm_3x3     ]:= tc_orange+'3x3'             +tc_default;
   str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'           +tc_default;
   str_gmode[gm_capture ]:= tc_aqua  +'Capturing points'+tc_default;
   str_gmode[gm_invasion]:= tc_blue  +'Invasion'        +tc_default;
   str_gmode[gm_KotH    ]:= tc_purple+'King of the Hill'+tc_default;
   str_gmode[gm_royale  ]:= tc_red   +'Royal Battle'    +tc_default;

   str_cgenerators       := 'Neutral generators lifetime:';
   str_cgeneratorsM[0]   := 'none';
   str_cgeneratorsM[1]   := '5 min';
   str_cgeneratorsM[2]   := '10 min';
   str_cgeneratorsM[3]   := '15 min';
   str_cgeneratorsM[4]   := '20 min';
   str_cgeneratorsM[5]   := 'infinity';

   str_team              := 'Team:';
   str_srace             := 'Race:';
   str_ready             := 'Ready: ';
   str_udpport           := 'UDP port:';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_pnu               := 'File size/quality: ';
   str_npnu              := 'Units update rate: ';
   str_connecting        := 'Connecting...';
   str_sver              := 'Wrong version!';
   str_sfull             := 'Server full!';
   str_sgst              := 'Game started!';

   str_hint_t[0]         := 'Buildings';
   str_hint_t[1]         := 'Units';
   str_hint_t[2]         := 'Researches';
   str_hint_t[3]         := 'Controls';

   str_hint_army         := 'Army: ';
   str_hint_energy       := 'Energy: ';

   str_hint_m[0]         := 'Menu (' +tc_lime+'Esc'+tc_default+')';
   str_hint_m[2]         := 'Pause ('+tc_lime+'Pause/Break'+tc_default+')';


   _mkHStrUid(UID_HKeep         ,'Hell Keep'          ,'Builder. Generates energy.'   );
   _mkHStrUid(UID_HGate         ,'Hell Gate'          ,'Summons units.'               );
   _mkHStrUid(UID_HSymbol       ,'Hell Symbol'        ,'Increase energy level.'       );
   _mkHStrUid(UID_HASymbol      ,'Hell Great Symbol'  ,'Increase energy level.'       );
   _mkHStrUid(UID_HPools        ,'Hell Pools'         ,'Researches and upgrades.'     );
   _mkHStrUid(UID_HTower        ,'Hell Tower'         ,'Defensive structure.'         );
   _mkHStrUid(UID_HTeleport     ,'Hell Teleport'      ,'Teleports units.'             );
   _mkHStrUid(UID_HMonastery    ,'Hell Monastery'     ,'Upgrades units.'              );
   _mkHStrUid(UID_HEyeNest      ,'Hell Eye Nest'      ,'Casts "Hell Vision"  effect on units. Detector.' );
   _mkHStrUid(UID_HTotem        ,'Hell Totem'         ,'Advanced defensive structure.');
   _mkHStrUid(UID_HAltar        ,'Hell Altar'         ,'Casts "Invulnerability" effect on units.'        );
   _mkHStrUid(UID_HFortress     ,'Hell Fortress'      ,'Upgrades production buildings. Generates energy.');
   _mkHStrUid(UID_HCommandCenter,'Hell Command Center','Corrupted UAC Command Center. Builder. Generates energy.');
   _mkHStrUid(UID_HMilitaryUnit ,'Hell Military Unit' ,'Corrupted UAC Military Unit. Creates zombies.' );
   _mkHStrUid(UID_HEye          ,'Hell Eye'           ,'Detection.');

   _mkHStrUid(UID_LostSoul       ,'Lost Soul'      ,'');
   _mkHStrUid(UID_Imp            ,'Imp'            ,'');
   _mkHStrUid(UID_Demon          ,'Demon'          ,'');
   _mkHStrUid(UID_Cacodemon      ,'Cacodemon'      ,'');
   _mkHStrUid(UID_Knight         ,'Hell Knight'    ,'');
   _mkHStrUid(UID_Baron          ,'Baron of Hell'  ,'');
   _mkHStrUid(UID_Cyberdemon     ,'Cyberdemon'     ,'');
   _mkHStrUid(UID_Mastermind     ,'Mastermind'     ,'');
   _mkHStrUid(UID_Pain           ,'Pain Elemental' ,'');
   _mkHStrUid(UID_Revenant       ,'Revenant'       ,'');
   _mkHStrUid(UID_Mancubus       ,'Mancubus'       ,'');
   _mkHStrUid(UID_Arachnotron    ,'Arachnotron'    ,'');
   _mkHStrUid(UID_Archvile       ,'ArchVile'       ,'');
   _mkHStrUid(UID_ZFormer        ,'Zombie Former'  ,'');
   _mkHStrUid(UID_ZEngineer      ,'Zombie Engineer','');
   _mkHStrUid(UID_ZSergant       ,'Zombie Shotguner','');
   _mkHStrUid(UID_ZSSergant      ,'Zombie SuperShotguner','');
   _mkHStrUid(UID_ZCommando      ,'Zombie Commando','');
   _mkHStrUid(UID_ZAntiaircrafter,'Antiaircrafter Zombie'  ,'');
   _mkHStrUid(UID_ZSiege         ,'Siege Zombie'   ,'');
   _mkHStrUid(UID_ZMajor         ,'Zombie Plasmaguner'        ,'');
   _mkHStrUid(UID_ZFMajor        ,'Zombie Jetpack Plasmaguner','');
   _mkHStrUid(UID_ZBFG           ,'Zombie BFG'     ,'');


   _mkHStrUpid(upgr_hell_teleport ,'Teleport upgrade'               ,'Decrease cooldown time of Hell Teleport.'                           );
   _mkHStrUpid(upgr_hell_b478tel  ,'Tower teleportation'            ,'Hell Towers and Hell Totems can teleporting to short distance.'  );


   _mkHStrUpid(upgr_hell_dattack  ,'Hell Firepower'             ,'Increase the damage of ranged attacks.'                              );
   _mkHStrUpid(upgr_hell_uarmor   ,'Combat Flesh'               ,'Increase the armor of Hell`s units.'                                 );
   _mkHStrUpid(upgr_hell_barmor   ,'Stone Walls'                ,'Increase the armor of Hell`s buildings.'                             );
   _mkHStrUpid(upgr_hell_mattack  ,'Claws and Teeth'            ,'Increase the damage of melee attacks.'                               );
  { _mkHStrUpid(upgr_regen   ,'Regeneration'               ,'Damaged units will slowly regenerate their health.'                        );
   _mkHStrUpid(upgr_pains   ,'Pain threshold'             ,'Decrease "pain state" chance.'                                             );
   _mkHStrUpid(upgr_vision  ,'Hell eye'                   ,'Lost Soul ability & Hell Eye sight radius.'                                );
   _mkHStrUpid(upgr_towers  ,'Tower range upgrade'        ,'Increase defensive structures range.'                                      );

   _mkHStrUpid(upgr_mainm   ,'Hell Keep teleportaion'     ,'Hell Keep can teleporting.'                                                );
   _mkHStrUpid(upgr_paina   ,'Decay aura'                 ,'Hell Keep will damage all enemies around.'                                 );
   _mkHStrUpid(upgr_mainr   ,'Hell Keep range upgrade'    ,'Increase Hell Keep sight range.'                                           );
   _mkHStrUpid(upgr_pinkspd ,'Demon`s anger'              ,'Increase Demon`s speed.'                                                   );
   _mkHStrUpid(upgr_misfst  ,'Firepower'                  ,'Increase missiles speed for Imp, Cacodemon and Baron of Hell/Hell Knight.' );
   _mkHStrUpid(upgr_6bld    ,'Hell power'                 ,'Allow Hell Monastery upgrades units.'                                      );
   _mkHStrUpid(upgr_2tier   ,'Ancient evil'               ,'New buildings, units and upgrades.'                                        );
   _mkHStrUpid(upgr_revtele ,'Reverse teleporting'        ,'Units can teleport back to Hell Teleport.'                           );
   _mkHStrUpid(upgr_revmis  ,'Revenant missile upgrade'   ,'Revenant missiles become homing.'                                    );
   _mkHStrUpid(upgr_totminv ,'Hell Totem and Eye invisibility',''                                                                );
   _mkHStrUpid(upgr_bldrep  ,'Building restoration'           ,'Damaged buildings will slowly regenerate their health.'          );
   _mkHStrUpid(upgr_mainonr ,'Free teleportation'             ,'Hell Keep can teleporting on obstacles.'                         );

   _mkHStrUpid(upgr_hinvuln ,'Invulnerability'                ,'Invulnerability spheres for Hell Altar.'                         );
   _mkHStrUpid(upgr_bldenrg ,'Built-in Hell Symbol'           ,'Additional energy for Hell Keep.'                                );
   _mkHStrUpid(upgr_9bld    ,'Hell Fortress upgrade'          ,'Decrease Fortress cooldown time.'                                );  }

   _mkHStrUid(UID_UCommandCenter   ,'UAC Command Center'         ,'Builder. Generates energy.'      );
   _mkHStrUid(UID_UMilitaryUnit    ,'UAC Military unit'          ,'Produces units.'                 );
   _mkHStrUid(UID_UFactory         ,'UAC Factory'                ,'Produces mech units.'            );
   _mkHStrUid(UID_UGenerator       ,'UAC Generator'              ,'Increase energy level.'          );
   _mkHStrUid(UID_UAGenerator      ,'UAC Advanced Generator'     ,'Increase energy level.'          );
   _mkHStrUid(UID_UWeaponFactory   ,'UAC Weapon Factory'         ,'Researches and upgrades.'        );
   _mkHStrUid(UID_UGTurret         ,'UAC Anti-ground turret'     ,'Anti-ground defensive structure.');
   _mkHStrUid(UID_UATurret         ,'UAC Anti-air turret'        ,'Anti-air defensive structure.'   );
   _mkHStrUid(UID_URadar           ,'UAC Radar'                  ,'Reveals map. Detector.'          );
   _mkHStrUid(UID_UTechCenter      ,'UAC Tech Center'            ,'Upgrades units.'                 );
   _mkHStrUid(UID_URMStation       ,'UAC Rocket Launcher Station','Provide a missile strike. Missile strike requires "Missile strike" research.');
   _mkHStrUid(UID_UNuclearPlant    ,'UAC Nuclear Plant'          ,'Upgrades production buildings. Generates energy.');
   _mkHStrUid(UID_UMine            ,'UAC Mine','');

   _mkHStrUid(UID_Sergant       ,'Shotguner'        ,'');
   _mkHStrUid(UID_SSergant      ,'SuperShotguner'   ,'');
   _mkHStrUid(UID_Commando      ,'Commando'         ,'');
   _mkHStrUid(UID_Antiaircrafter,'Antiaircrafter'   ,'');
   _mkHStrUid(UID_Siege         ,'Siege Marine'     ,'');
   _mkHStrUid(UID_Major         ,'Plasmaguner'      ,'');
   _mkHStrUid(UID_FMajor        ,'Jatpack Plasmaguner','');
   _mkHStrUid(UID_BFG           ,'BFG Marine'       ,'');
   _mkHStrUid(UID_Engineer      ,'Engineer'         ,'');
   _mkHStrUid(UID_Medic         ,'Medic'            ,'');
   _mkHStrUid(UID_FAPC          ,'Air APC'          ,'');
   _mkHStrUid(UID_UTransport    ,'Air APC'          ,'');
   _mkHStrUid(UID_APC           ,'Ground APC'       ,'');
   _mkHStrUid(UID_UACBot        ,'UAC Bot'          ,'');
   _mkHStrUid(UID_Terminator    ,'UAC Terminator'   ,'');
   _mkHStrUid(UID_Tank          ,'UAC Tank'         ,'');
   _mkHStrUid(UID_Flyer         ,'UAC Fighter'      ,'');


   _mkHStrUpid(upgr_uac_jetpack,'Jatpacks',''     );
   _mkHStrUpid(upgr_uac_radar_r,'UAC Radar upgrade','Increase radar scouting radius.'     );
   _mkHStrUpid(upgr_uac_rstrike,'UAC Rocket strike','Missile for Rocket Launcher Station.');

   {_mkHStrUpid(upgr_attack  ,'Ranged attack upgrade'  ,'Increase ranged attacks damage.'                                    );
   _mkHStrUpid(upgr_armor   ,'Infantry armor upgrade' ,'Increase infantry armor.'                                           );
   _mkHStrUpid(upgr_build   ,'Buildings armor upgrade','Increase buildings armor.'                                          );
   _mkHStrUpid(upgr_melee   ,'Advanced repairing and healing'
                                                             ,'Increases the efficiency of repair/healing of Engineers/Medics.'    );
   _mkHStrUpid(upgr_mspeed  ,'Lightweight armor'      ,'Increase infantry move speed.'                                      );
   _mkHStrUpid(upgr_plsmt   ,'APC turret'             ,'Weapon for APCs.'                                                   );
   _mkHStrUpid(upgr_vision  ,'Detector device'        ,'UAC Radar and UAC Mines becomes detectors.'                         );
   _mkHStrUpid(upgr_towers  ,'Turrets range upgrade'  ,'Increase defensive structures range.'                               );
   _mkHStrUpid(upgr_5bld    ,'UAC Radar upgrade'          ,'Increase radar scouting time and it sight radius.'                  );
   _mkHStrUpid(upgr_mainm   ,'UAC Command Center engines' ,'UAC Command Center gains ability to fly.'                           );
   _mkHStrUpid(upgr_ucomatt ,'UAC Command Center turret'  ,'Flying UAC Command Center will be able to attack.'                  );
   _mkHStrUpid(upgr_mainr   ,'UAC Command Center range'   ,'Increase UAC Command Center sight range.'                           );
   _mkHStrUpid(upgr_mines   ,'UAC Mines'                  ,'Engineer ability.'                                                  );
   _mkHStrUpid(upgr_minesen ,'Mine-sensor'            ,'UAC Mine ability.'                                                  );
   _mkHStrUpid(upgr_6bld    ,'Advanced armory'        ,'Allow UAC Tech Center upgrades units.'                              );
   _mkHStrUpid(upgr_2tier   ,'High technologies'      ,'New buildings, units and upgrades.'               );
   _mkHStrUpid(upgr_blizz   ,'Missile strike'         ,'Missile for Rocket Launcher Station.'             );
   _mkHStrUpid(upgr_mechspd ,'Advanced engines'       ,'Increase mechs move speed.'                       );
   _mkHStrUpid(upgr_mecharm ,'Mech armor upgrade'     ,'Increase mechs armor.'                            );
   _mkHStrUpid(upgr_6bld2   ,'Fast rearming'          ,'Decrease UAC Tech Center cooldown time.'          );
   _mkHStrUpid(upgr_mainonr ,'Free placement'         ,'UAC Command center can land on obstacles.'        );
   _mkHStrUpid(upgr_turarm  ,'UAC Turrets armor'      ,'Additional armor for turrets.'                    );
   _mkHStrUpid(upgr_rturrets,'UAC Rocket turrets'     ,'UAC Turrets can upgrade to Rocket turrets.'       );
   _mkHStrUpid(upgr_bldenrg ,'Built-in generator'     ,'Additional energy for UAC Command Center.'        );
   _mkHStrUpid(upgr_9bld    ,'UAC Nuclear Plant upgrade','Decrease UAC Nuclear Plant cooldown time.'      ); }

   _mkHStrACT(0 ,'Action ');
   _mkHStrACT(1 ,'Action at point ');
   _mkHStrACT(2 ,str_maction);
   t:='attack enemies';
   _mkHStrACT(3 ,'Move, '  +t);
   _mkHStrACT(4 ,'Stop, '  +t);
   _mkHStrACT(5 ,'Patrol, '+t);
   t:='ignore enemies';
   _mkHStrACT(6 ,'Move, '  +t);
   _mkHStrACT(7 ,'Stop, '  +t);
   _mkHStrACT(8 ,'Patrol, '+t);
   _mkHStrACT(9 ,'Cancel production');
   _mkHStrACT(10,'Select all units' );
   _mkHStrACT(11,'Destroy'          );


   _mkHStrREQ(0 ,'Faster game speed'    ,false);
   _mkHStrREQ(1 ,'Left click: skip 2 seconds ('                                +tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Right click: skip 10 seconds ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                 'Skip 1 minute ('               +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true);
   _mkHStrREQ(2 ,'Pause'                ,false);
   _mkHStrREQ(3 ,'Player POV'           ,false);
   _mkHStrREQ(4 ,'List of game messages',false);
   _mkHStrREQ(5 ,'Fog of war'           ,false);
   _mkHStrREQ(8 ,'All players',false);
   _mkHStrREQ(9 ,'Player #1'  ,false);
   _mkHStrREQ(10,'Player #2'  ,false);
   _mkHStrREQ(11,'Player #3'  ,false);
   _mkHStrREQ(12,'Player #4'  ,false);
   _mkHStrREQ(13,'Player #5'  ,false);
   _mkHStrREQ(14,'Player #6'  ,false);


   {str_camp_t[0]         := 'Hell #1: Phobos invasion';
   str_camp_t[1]         := 'Hell #2: Military base';
   str_camp_t[2]         := 'Hell #3: Deimos invasion';
   str_camp_t[3]         := 'Hell #4: Pentagram of Death';
   str_camp_t[4]         := 'Hell #7: Quarry';
   str_camp_t[5]         := 'Hell #8: Hell on Mars';
   str_camp_t[6]         := 'Hell #5: Hell on Earth';
   str_camp_t[7]         := 'Hell #6: Cosmodrome';
   str_camp_t[8]         := '9. ';
   str_camp_t[9]         := '10. ';
   str_camp_t[10]        := '11. ';
   str_camp_t[11]        := '12. ';
   str_camp_t[12]        := '13. ';
   str_camp_t[13]        := '14. ';
   str_camp_t[14]        := '15. ';
   str_camp_t[15]        := '16. ';
   str_camp_t[16]        := '17. ';
   str_camp_t[17]        := '18. ';
   str_camp_t[18]        := '19. ';
   str_camp_t[19]        := '20. ';
   str_camp_t[20]        := '21. ';
   str_camp_t[21]        := '22. ';

   str_camp_o[0]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[1]         := '-Destroy Military Base';
   str_camp_o[2]         := '-Destroy all human bases and armies'+tc_nl3+'-Protect the Portal';
   str_camp_o[3]         := '-Protect the altars for 20 minutes';
   str_camp_o[4]         := '-Destroy all human bases and armies';
   str_camp_o[5]         := '-Destroy all human bases and armies';
   str_camp_o[6]         := '-Destroy all human bases and armies';
   str_camp_o[7]         := '-Destroy Cosmodrome'+tc_nl3+'-No one human`s transport should escape';

   str_camp_m[0]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[1]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'PHOBOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hall crater';
   str_camp_m[2]         := tc_lime+'Date:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Anomaly Zone';
   str_camp_m[3]         := tc_lime+'Date:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'DEIMOS'+tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Swift crater';
   str_camp_m[4]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[5]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'MARS'  +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Hellas Area';
   str_camp_m[6]         := tc_lime+'Date:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';
   str_camp_m[7]         := tc_lime+'Date:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Location:'+tc_default+tc_nl2+'EARTH' +tc_nl2+tc_lime+'Area:'+tc_default+tc_nl2+'Unknown';  }

   {
   str_cmp_mn[1 ] := 'Hell #1: Invasion on Phobos';
   str_cmp_mn[2 ] := 'Hell #2: Toxin Refinery';
   str_cmp_mn[3 ] := 'Hell #3: Military Base';
   str_cmp_mn[4 ] := 'Hell #4: Deimos Anomaly';
   str_cmp_mn[5 ] := 'Hell #5: Nuclear Plant';
   str_cmp_mn[6 ] := 'Hell #6: Science Center';
   str_cmp_mn[7 ] := 'Hell #7: Quarry';
   str_cmp_mn[8 ] := 'Hell #8: Hell on Mars';
   str_cmp_mn[9 ] := 'Hell #9: Hell On Earth';
   str_cmp_mn[10] := 'Hell #10: Industrial Zone';
   str_cmp_mn[11] := 'Hell tc_nl1: Cosmodrome';
   str_cmp_mn[12] := 'UAC #1: Command Center';
   str_cmp_mn[13] := 'UAC #2: Super Generators';
   str_cmp_mn[14] := 'UAC #3: Phobos Anomaly';
   str_cmp_mn[15] := 'UAC #4: Deimos Anomaly 2';
   str_cmp_mn[16] := 'UAC #5: Lab';
   str_cmp_mn[17] := 'UAC #6: Fortress of Mystery';
   str_cmp_mn[18] := 'UAC #7: City of the Damned';
   str_cmp_mn[19] := 'UAC #8: Slough of Despair';
   str_cmp_mn[20] := 'UAC #9: Mt. Erebus';
   str_cmp_mn[21] := 'UAC #10: Dead Zone';
   str_cmp_mn[22] := 'UAC tc_nl1: Battle For Mars';

   str_cmp_ob[1 ] := '-Destroy all human bases and armies'+tc_nl3+'-Protect portal';
   str_cmp_ob[2 ] := '-Destroy Toxin Refinery';
   str_cmp_ob[3 ] := '-Destroy Military Base';
   str_cmp_ob[4 ] := '-Destroy all human bases and armies'+tc_nl3+'-Cyberdemon must survive'+tc_nl3+'-Protect portal';
   str_cmp_ob[5 ] := '-Destroy Nuclear Plant'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[6 ] := '-Destroy Science Center'+tc_nl3+'-Cyberdemon must survive';
   str_cmp_ob[7 ] := '-Destroy all human bases and armies';
   str_cmp_ob[8 ] := '-Kill all humans!';
   str_cmp_ob[9 ] := '-Protect Hell Fortess'+tc_nl3+'-Destroy all human towns and armies';
   str_cmp_ob[10] := '-Destroy all industrial buildings'+tc_nl3+'-Destroy all command centers';
   str_cmp_ob[11] := '-Destroy all military bases';
   str_cmp_ob[12] := '-Find, protect and reapir'+tc_nl3+'Command Center'+tc_nl3+'-At least one engineer must survive';
   str_cmp_ob[13] := '-Find and repair 5 Super Generators';
   str_cmp_ob[14] := '-Destroy all bases and armies of hell'+tc_nl3+'around portal until the arrival of'+tc_nl3+'enemy reinforcements(for 20 minutes)';
   str_cmp_ob[15] := '-Destroy all bases and armies of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[16] := '-Repair and protect Science Center'+tc_nl3+'-Destroy all bases and armies of hell';
   str_cmp_ob[17] := '-Destroy fortess of hell';
   str_cmp_ob[18] := '-Destroy all altars of hell'+tc_nl3+'-Protect portal';
   str_cmp_ob[19] := '-Reach the opposite side of the area';
   str_cmp_ob[20] := '-Find and kill the Spiderdemon';
   str_cmp_ob[21] := '-Cleanse the Quarry';
   str_cmp_ob[22] := '-Destroy all bases and armies of hell';

   str_cmp_map[1 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[2 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Hall crater';
   str_cmp_map[3 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Drunlo crater';
   str_cmp_map[4 ] := 'Date:'+tc_nl2+'15.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[5 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Swift crater';
   str_cmp_map[6 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[7 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[8 ] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[9 ] := 'Date:'+tc_nl2+'25.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[10] := 'Date:'+tc_nl2+'26.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[11] := 'Date:'+tc_nl2+'27.11.2145'+tc_nl2+'Location:'+tc_nl2+'EARTH' +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[12] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Todd crater';
   str_cmp_map[13] := 'Date:'+tc_nl2+'16.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Roche crater';
   str_cmp_map[14] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'PHOBOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[15] := 'Date:'+tc_nl2+'17.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Anomaly Zone';
   str_cmp_map[16] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[17] := 'Date:'+tc_nl2+'18.11.2145'+tc_nl2+'Location:'+tc_nl2+'DEIMOS'+tc_nl2+'Area:'+tc_nl2+'Voltaire Area';
   str_cmp_map[18] := 'Date:'+tc_nl2+'20.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[19] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[20] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'HELL'  +tc_nl2+'Area:'+tc_nl2+'Unknown';
   str_cmp_map[21] := 'Date:'+tc_nl2+'21.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';
   str_cmp_map[22] := 'Date:'+tc_nl2+'22.11.2145'+tc_nl2+'Location:'+tc_nl2+'MARS'  +tc_nl2+'Area:'+tc_nl2+'Hellas Area';

   }

   _makeHints;
end;

procedure lng_rus;
var t: shortstring;
begin
  str_MMap              := 'КАРТА';
  str_MPlayers          := 'ИГРОКИ';
  str_MObjectives       := 'ЗАДАЧИ';
  str_menu_s1[ms1_sett] := 'НАСТРОЙКИ';
  str_menu_s1[ms1_svld] := 'СОХР./ЗАГР.';
  str_menu_s1[ms1_reps] := 'ЗАПИСИ';
  str_menu_s2[ms2_camp] := 'КАМПАНИИ';
  str_menu_s2[ms2_scir] := 'СХВАТКА';
  str_menu_s2[ms2_mult] := 'СЕТЕВАЯ ИГРА';
  str_menu_s3[ms3_game] := 'ИГРА';
  str_menu_s3[ms3_vido] := 'ГРАФИКА';
  str_menu_s3[ms3_sond] := 'ЗВУК';
  str_reset[false]      := 'НАЧАТЬ';
  str_reset[true ]      := 'СБРОС';
  str_exit[false]       := 'ВЫХОД';
  str_exit[true]        := 'НАЗАД';
  str_m_liq             := 'Озера: ';
  str_m_siz             := 'Размер: ';
  str_m_obs             := 'Преграды: ';
  str_m_sym             := 'Симметр.: ';
  str_map               := 'Карта';
  str_players           := 'Игроки';
  str_mrandom           := 'Случайная карта';
  str_musicvol          := 'Громкость музыки';
  str_soundvol          := 'Громкость звуков';
  str_scrollspd         := 'Скорость пр.';
  str_mousescrl         := 'Прокр. мышью:';
  str_fullscreen        := 'В окне:';
  str_plname            := 'Имя игрока';
  str_maction           := 'Действие на правый клик';
  str_maction2[true ]   := tc_lime+'движение'+tc_default;
  str_maction2[false]   := tc_lime+'движ.'   +tc_default+'+'+tc_red+'атака'+tc_default;
  str_race[r_random]    := tc_white+'случ.'  +tc_default;
  str_pause             := 'Пауза';
  str_win               := 'ПОБЕДА!';
  str_lose              := 'ПОРАЖЕНИЕ!';
  str_gsunknown         := 'Неизвестный статус!';
  str_gsaved            := 'Игра сохранена';
  str_repend            := 'Конец записи!';
  str_save              := 'Сохранить';
  str_load              := 'Загрузить';
  str_delete            := 'Удалить';
  str_svld_errors[1]    := 'Файл не'+tc_nl3+'существует!';
  str_svld_errors[2]    := 'Невозможно'+tc_nl3+'открыть файл!';
  str_svld_errors[3]    := 'Неправильный'+tc_nl3+'размер файла!';
  str_svld_errors[4]    := 'Неправильная'+tc_nl3+'версия файла!';
  str_time              := 'Время: ';
  str_menu              := 'Меню';
  str_player_def        := ' уничтожен!';
  str_inv_time          := 'Волна #';
  str_inv_ml            := 'Монстры: ';
  str_play              := 'Проиграть';
  str_replay            := 'ЗАПИСЬ';
  str_cmpdif            := 'Сложность: ';
  str_waitsv            := 'Ожидание сервера...';
  str_goptions          := 'ПАРАМЕТРЫ ИГРЫ';
  str_server            := 'СЕРВЕР';
  str_client            := 'КЛИЕНТ';
  str_chat              := 'ЧАТ';
  str_randoms           := 'Случайная схватка';
  str_apply             := 'применить';
  str_plout             := ' покинул игру';
  str_aislots           := 'Заполнить пустые слоты:';
  str_cgenerators       := 'Захват генераторов:';
  str_chattars          := 'Адресаты';
  str_resol             := 'Разрешение';
  str_language          := 'Язык интерфейса';
  str_req               := 'Требования: ';
  str_orders            := 'Отряды: ';
  str_all               := 'Все';
  str_uprod             := 'Создается в: ';
  str_bprod             := 'Строит: ';
  str_cant_build        := 'Нельзя строить здесь!';
  str_need_energy       := 'Необходимо больше энергии!';
  str_cant_prod         := 'Невоможно произвести это!';
  str_check_reqs        := 'Проверьте требования!';

  str_advanced          := 'Улучшенный ';
  str_unit_advanced     := 'Юнит улучшен';
  str_upgrade_complete  := 'Исследование завершено';
  str_building_complete := 'Постройка завершена';
  str_unit_complete     := 'Юнит готов';

  str_attr_unit         := tc_gray  +'юнит'          +tc_default;
  str_attr_building     := tc_red   +'здание'        +tc_default;
  str_attr_mech         := tc_blue  +'механический'  +tc_default;
  str_attr_bio          := tc_orange+'биологический' +tc_default;
  str_attr_light        := tc_yellow+'легкий'        +tc_default;
  str_attr_nlight       := tc_green +'тяжелый'       +tc_default;
  str_attr_fly          := tc_white +'летающий'      +tc_default;
  str_attr_ground       := tc_lime  +'наземный'      +tc_default;
  str_attr_floater      := tc_aqua  +'парящий'       +tc_default;
  str_attr_level        := tc_white +'уровень '      ;
  str_attr_invuln       := tc_lime  +'неуязвимый'    +tc_default;
  str_attr_stuned       := tc_yellow+'парализованный'+tc_default;
  str_attr_detector     := tc_purple+'детектор'      +tc_default;

  str_panelpos          := 'Положение игровой панели';
  str_panelposp[0]      := tc_lime  +'слева' +tc_default;
  str_panelposp[1]      := tc_orange+'справа'+tc_default;
  str_panelposp[2]      := tc_yellow+'вверху'+tc_default;
  str_panelposp[3]      := tc_aqua  +'внизу' +tc_default;

  str_uhbar             := 'Полоски здоровья';
  str_uhbars[0]         := tc_lime  +'выбранные'+tc_default+'+'+tc_red+'поврежд.'+tc_default;
  str_uhbars[1]         := tc_aqua  +'всегда'   +tc_default;
  str_uhbars[2]         := tc_orange+'только '  +tc_lime+'выбранные'+tc_default;

  str_pcolor            := 'Цвета игроков';
  str_pcolors[0]        := tc_white +'по умолчанию'+tc_default;
  str_pcolors[1]        := tc_lime  +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_pcolors[2]        := tc_white +'свои '+tc_yellow+'союзники '+tc_red+'враги'+tc_default;
  str_pcolors[3]        := tc_purple+'команды'+tc_default;
  str_pcolors[4]        := tc_white +'свои '+tc_purple+'команды'+tc_default;

  str_starta            := 'Количество строителей на старте:';

  str_sstarts           := 'Показывать старты:';

  str_gmodet            := 'Режим игры:';
  str_gmode[gm_scirmish]:= tc_lime  +'Схватка'           +tc_default;
  str_gmode[gm_3x3     ]:= tc_orange+'3x3'               +tc_default;
  str_gmode[gm_2x2x2   ]:= tc_yellow+'2x2x2'             +tc_default;
  str_gmode[gm_capture ]:= tc_aqua  +'Захват точек'      +tc_default;
  str_gmode[gm_invasion]:= tc_blue  +'Вторжение'         +tc_default;
  str_gmode[gm_KotH    ]:= tc_purple+'Царь горы'         +tc_default;
  str_gmode[gm_royale  ]:= tc_red   +'Королевская битва' +tc_default;

  str_team              := 'Клан:';
  str_srace             := 'Раса:';
  str_ready             := 'Готов: ';
  str_udpport           := 'UDP порт:';
  str_svup[false]       := 'Вкл. сервер';
  str_svup[true ]       := 'Выкл. сервер';
  str_connect[false]    := 'Подключится';
  str_connect[true ]    := 'Откл.';
  str_pnu               := 'Размер/качество: ';
  str_npnu              := 'Обновление юнитов: ';
  str_connecting        := 'Соединение...';
  str_sver              := 'Другая версия!';
  str_sfull             := 'Нет мест!';
  str_sgst              := 'Игра началась!';

  str_hint_t[0]         := 'Здания';
  str_hint_t[1]         := 'Юниты';
  str_hint_t[2]         := 'Исследования';
  str_hint_t[3]         := 'Запись';

  str_hint_m[0]         := 'Меню (' +tc_lime+'Esc'        +tc_default+')';
  str_hint_m[2]         := 'Пауза ('+tc_lime+'Pause/Break'+tc_default+')';

  str_hint_army         := 'Армия: ';
  str_hint_energy       := 'Энергия: ';

  _mkHStrUid(UID_HKeep         ,'Адская Крепость' ,'Строит базу. Увеличивает энергию.'     );
  _mkHStrUid(UID_HGate         ,'Адские Врата'    ,'Призывает юнитов.'                     );
  _mkHStrUid(UID_HSymbol       ,'Адский Символ'   ,'Увеличивает энергию.'                  );
  _mkHStrUid(UID_HPools        ,'Адские Омуты'    ,'Исследования и улучшения.'             );
  _mkHStrUid(UID_HTower        ,'Адская Башня'    ,'Защитное сооружение.'                  );
  _mkHStrUid(UID_HTeleport     ,'Адский Телепорт' ,'Телепортирует юнитов.'                 );
  _mkHStrUid(UID_HMonastery    ,'Адский Монастырь','Улучшает юнитов.'                      );
  _mkHStrUid(UID_HTotem        ,'Адский Тотем'    ,'Продвинутое защитное сооружение.'      );
  _mkHStrUid(UID_HAltar        ,'Адский Алтарь'   ,'Временно делает юнитов неуязвимыми.'   );
  _mkHStrUid(UID_HFortress     ,'Адский Замок'    ,'Позволяет улучшать производственные здания. Производит энергию. Может строить.'   );
  _mkHStrUid(UID_HCommandCenter,'Проклятый Командный Центр','Строит базу. Увеличивает энергию.');
  _mkHStrUid(UID_HMilitaryUnit ,'Проклятая Войсковая часть','Производит зомби.' );

 { _mkHStrUpid(upgr_attack  ,'Улучшение дальней атаки'        ,''                                         );
  _mkHStrUpid(upgr_armor   ,'Улучшение защиты юнитов'        ,''                                         );
  _mkHStrUpid(upgr_build   ,'Улучшение защиты зданий'        ,''                                         );
  _mkHStrUpid(upgr_melee   ,'Улучшение ближней атаки'        ,''                                         );
  _mkHStrUpid(upgr_regen   ,'Регенерация'                    ,'Раненые юниты медленно восстанавливают свое здоровье.'                   );
  _mkHStrUpid(upgr_pains   ,'Болевой порог'                  ,'Уменьшение шанса "pain state".'                                          );
  _mkHStrUpid(upgr_vision  ,'Адский глаз'                    ,'Способность Lost Soul и радиус зрения Адского Глаза.'                    );
  _mkHStrUpid(upgr_towers  ,'Радиус атаки башен'             ,'Увеличение радиуса атаки и зрения защитных сооружений.'                  );
  _mkHStrUpid(upgr_5bld    ,'Улучшение телепорта'            ,'Уменьшение время перезарядки Телепорта.'                                 );
  _mkHStrUpid(upgr_mainm   ,'Телепортация адской крепости'   ,'Адская Крепость может перемещаться в любую свободную точку карты.'       );
  _mkHStrUpid(upgr_paina   ,'Аура разрушения'                ,'Адская крепость наносит урон всем врагам вокруг.'                        );
  _mkHStrUpid(upgr_mainr   ,'Радиус зрения адской крепости'  ,'Увеличение радиуса зрения и дистанции строительства для Aдской Крепости.');
  _mkHStrUpid(upgr_pinkspd ,'Злость демона'                  ,'Увеличение скорости юнита Demon.'                                        );
  _mkHStrUpid(upgr_6bld    ,'Адска сила'                     ,'Позволяет Адскому Монастырю улучшать своих юнитов.'                      );
  _mkHStrUpid(upgr_misfst  ,'Огневая мощь'                   ,'Увеличение скорсоти полета снарядов юнитов Imp, Cacodemon и Baron of Hell/Hell Knight.'                              );
  _mkHStrUpid(upgr_2tier   ,'Древнее зло'                    ,'Второй уровень зданий, юнитов и улучшений.'                              );
  _mkHStrUpid(upgr_revtele ,'Обратный телепорт'              ,'Юниты могут перемещаться обратно в Адский Телепорт.'                     );
  _mkHStrUpid(upgr_revmis  ,'Улучшение атаки юнита Revenant' ,'Снаряды становятся самонаводящимися.'                                    );
  _mkHStrUpid(upgr_totminv ,'Невидимость для Тотема и Глаза' ,'Адский Тотем и Глаз становятся невидимыми.'                              );
  _mkHStrUpid(upgr_bldrep  ,'Восстановление зданий'          ,'Поврежденные здания медленно восстанавливают себя.'                      );
  _mkHStrUpid(upgr_mainonr ,'Свободная телепортация'         ,'Адская Крепость может перемещаться на скалы, озера и др. препятствия.'   );
  _mkHStrUpid(upgr_b478tel ,'Телепортация на короткие дистанции'
                                                                    ,'Адские Символы, Башни и Тотемы могут телепортироваться на короткое расстояние.');
  _mkHStrUpid(upgr_hinvuln ,'Неуязвимость'                   ,'Сферы неуязвимости для Адского Алтаря.'                                  );
  _mkHStrUpid(upgr_bldenrg ,'Встроеный адский символ'        ,'Дополнительная энергия для Адской Крепости.'                             );
  _mkHStrUpid(upgr_9bld    ,'Улучшение Адского Замка'        ,'Уменьшение перезарядки.'                                                 ); }


  _mkHStrUid(UID_UCommandCenter  ,'Командный Центр'        ,'Строит базу. Увеличивает энергию.');
  _mkHStrUid(UID_UMilitaryUnit   ,'Войсковая Часть'        ,'Производит тренирует пехоту.'     );
  _mkHStrUid(UID_UFactory        ,'Фабрика'                ,'Производит технику.'              );
  _mkHStrUid(UID_UGenerator      ,'Генератор'              ,'Увеличивает энергию.'             );
  _mkHStrUid(UID_UWeaponFactory  ,'Завод Вооружений'       ,'Исследования и улучшения.'        );
  _mkHStrUid(UID_UGTurret        ,'Анти-наземная Турель'   ,'Защитное сооружение.'             );
  _mkHStrUid(UID_URadar          ,'Радар'                  ,'Раскрывает карту.'                );
  _mkHStrUid(UID_UTechCenter     ,'Технический Центр'      ,'Улучшает юнитов.'                 );
  _mkHStrUid(UID_URMStation        ,'Станция Ракетного Залпа','Производит ракетный удар. Для залпа требуется исследование "Ракетный удар".');
  _mkHStrUid(UID_UATurret        ,'Анти-воздушная Турель'  ,'Защитное сооружение.');
  _mkHStrUid(UID_UNuclearPlant   ,'АЭС'                    ,'Позволяет улучшать производственные здания. Производит энергию.');
  _mkHStrUid(UID_UMine           ,'Мина','');

  _mkHStrUid(UID_Engineer   ,'Инженер'            ,'');
  _mkHStrUid(UID_Medic      ,'Медик'              ,'');
  _mkHStrUid(UID_Sergant    ,'Сержант'            ,'');
  _mkHStrUid(UID_Commando   ,'Коммандо'           ,'');
  _mkHStrUid(UID_Antiaircrafter     ,'Гранатометчик'      ,'');
  _mkHStrUid(UID_Major      ,'Майор'              ,'');
  _mkHStrUid(UID_BFG        ,'Солдат с BFG'       ,'');
  _mkHStrUid(UID_FAPC       ,'Воздушный транспорт','');
  _mkHStrUid(UID_UTransport ,'Воздушный транспорт','');
  _mkHStrUid(UID_APC        ,'БТР'                ,'');
  _mkHStrUid(UID_Terminator ,'Терминатор'         ,'');
  _mkHStrUid(UID_Tank       ,'Танк'               ,'');
  _mkHStrUid(UID_Flyer      ,'Истребитель'        ,'');

  {_mkHStrUpid(upgr_attack  ,'Улучшение дальней атаки'    ,''                                );
  _mkHStrUpid(upgr_armor   ,'Улучшение защиты пехоты'    ,''                                );
  _mkHStrUpid(upgr_build   ,'Улучшение защиты зданий'    ,''                                );
  _mkHStrUpid(upgr_melee   ,'Ремонт и лечение'           ,'Увеличение эффективности ремонта Инженером и лечения Медиком.');
  _mkHStrUpid(upgr_mspeed  ,'Легковесная броня'          ,'Увеличение скорости передвижения пехоты.'                 );
  _mkHStrUpid(upgr_plsmt   ,'Турель на транспорте'       ,'Оружие для транспортников.'                               );
  _mkHStrUpid(upgr_vision  ,'Детекторы'                  ,'Радар и Мины становятся детекторами.'                     );
  _mkHStrUpid(upgr_towers  ,'Радиус атаки турелей'       ,'Увеличение радиуса атаки и зрения защитных сооружений.'   );
  _mkHStrUpid(upgr_5bld    ,'Улучшение радара'           ,'Увеличивает радиус и время разведки Радара.'              );
  _mkHStrUpid(upgr_mainm   ,'Двигатели Командного центра','Командный Центр может летать.'                            );
  _mkHStrUpid(upgr_ucomatt ,'Турель Командного центра'   ,'Летающий Командный Центр может атаковать.'                );
  _mkHStrUpid(upgr_mainr   ,'Радиус зрения Командного центра','Увеличивает радиус зрения и дистанции строительства Командного Центра.');
  _mkHStrUpid(upgr_mines   ,'Мины'                       ,'Способность Инженера.'                                    );
  _mkHStrUpid(upgr_minesen ,'Мина-сенсор'                ,'Способность Мин.'                                         );
  _mkHStrUpid(upgr_6bld    ,'Дополнительное вооружение'  ,'Технический Центр может улучшать юнитов.'                 );
  _mkHStrUpid(upgr_2tier   ,'Выские технологии'          ,'Второй уровень зданий, юнитов и улучшений.'               );
  _mkHStrUpid(upgr_blizz   ,'Ракетный удар'              ,'Снаряд для станции Ракетного Залпа.'                      );
  _mkHStrUpid(upgr_mechspd ,'Продвинутые двигатели'      ,'Увеличение скорости передвижения техники.'                );
  _mkHStrUpid(upgr_mecharm ,'Улучшение защиты техники'   ,''                             );
  _mkHStrUpid(upgr_6bld2   ,'Быстрое перевооружение'     ,'Уменьшение времени парезарядки Технического Центра при улучшении юнитов.');
  _mkHStrUpid(upgr_mainonr ,'Свободное приземление'      ,'Командный Центр может приземляться на камни, озера и др. препятствия.');
  _mkHStrUpid(upgr_turarm  ,'Защита для турелей'         ,'Дополнительное увеличение защиты Турелей.'                );
  _mkHStrUpid(upgr_rturrets,'Ракетные турели'            ,'Обычные турели могут быть улучшены до ракетных.'          );
  _mkHStrUpid(upgr_bldenrg ,'Встроенный генератор'       ,'Дополнительна энергия для Командного Центра.'             );
  _mkHStrUpid(upgr_9bld    ,'Улучшение АЭС'              ,'Уменьшение времени парезарядки АЭС.'                      );  }

  _mkHStrACT(0 ,'Действие');
  _mkHStrACT(1 ,'Действие в точке');
  _mkHStrACT(2 ,str_maction);
  t:='атаковать врагов';
  _mkHStrACT(3 ,'Двигаться, '    +t);
  _mkHStrACT(4 ,'Стоять, '       +t);
  _mkHStrACT(5 ,'Патрулировать, '+t);
  t:='игнорировать врагов';
  _mkHStrACT(6 ,'Двигаться, '    +t);
  _mkHStrACT(7 ,'Стоять, '       +t);
  _mkHStrACT(8 ,'Патрулировать, '+t);
  _mkHStrACT(9 ,'Отмена производства');
  _mkHStrACT(10,'Выбрать всех боевых незанятых юнитов');
  _mkHStrACT(11,'Уничтожить');


  _mkHStrREQ(0 ,'Включить/выключить ускоренный просмотр',false);
  _mkHStrREQ(1 ,'Левый клик: пропустить 2 секунды ('                               +tc_lime+'W'+tc_default+')'+tc_nl1+
                'Правый клик: пропустить 10 секунд ('+tc_lime+'Ctrl'+tc_default+'+'+tc_lime+'W'+tc_default+')'+tc_nl1+
                'Пропустить 1 минуту ('              +tc_lime+'Alt' +tc_default+'+'+tc_lime+'W'+tc_default+')',true  );
  _mkHStrREQ(2 ,'Пауза'                   ,false);
  _mkHStrREQ(3 ,'Камера игрока'           ,false);
  _mkHStrREQ(4 ,'Список игровых сообщений',false);
  _mkHStrREQ(5 ,'Туман войны'             ,false);
  _mkHStrREQ(8 ,'Все игроки'              ,false);
  _mkHStrREQ(9 ,'Игрок #1',false);
  _mkHStrREQ(10,'Игрок #2',false);
  _mkHStrREQ(11,'Игрок #3',false);
  _mkHStrREQ(12,'Игрок #4',false);
  _mkHStrREQ(13,'Игрок #5',false);
  _mkHStrREQ(14,'Игрок #6',false);


  {str_camp_t[0]         := 'Hell #1: Вторжение на Фобос';
  str_camp_t[1]         := 'Hell #2: Военная база';
  str_camp_t[2]         := 'Hell #3: Вторжение на Деймос';
  str_camp_t[3]         := 'Hell #4: Пентаграмма смерти';
  str_camp_t[4]         := 'Hell #7: Каньон';
  str_camp_t[5]         := 'Hell #8: Ад на Марсе';
  str_camp_t[6]         := 'Hell #5: Ад на Земле';
  str_camp_t[7]         := 'Hell #6: Космодром';

  str_camp_o[0]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_o[1]         := '-Уничтожь военную базу';
  str_camp_o[2]         := '-Уничтожь все людские базы и армии'+tc_nl3+'-Защити портал';
  str_camp_o[3]         := '-Защити алтари в течении 20 минут';
  str_camp_o[4]         := '-Уничтожь все людские базы и армии';
  str_camp_o[5]         := '-Уничтожь все людские базы и армии';
  str_camp_o[6]         := '-Уничтожь все людские базы и армии';
  str_camp_o[7]         := '-Уничтожь космодром'+tc_nl3+'-Ни один людской транспорт не должен'+tc_nl3+'уйти';

  str_camp_m[0]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_m[1]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ФОБОС' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Халл';
  str_camp_m[2]         := tc_lime+'Дата:'+tc_default+tc_nl2+'15.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Аномалия';
  str_camp_m[3]         := tc_lime+'Дата:'+tc_default+tc_nl2+'16.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ДЕЙМОС'+tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Кратер Свифт';
  str_camp_m[4]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_m[5]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'МАРС'  +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Равнина Хеллас';
  str_camp_m[6]         := tc_lime+'Дата:'+tc_default+tc_nl2+'18.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';
  str_camp_m[7]         := tc_lime+'Дата:'+tc_default+tc_nl2+'19.11.2145'+tc_nl2+tc_lime+'Место:'+tc_default+tc_nl2+'ЗЕМЛЯ' +tc_nl2+tc_lime+'Район:'+tc_default+tc_nl2+'Неизвестно';  }

  _makeHints;
end;


procedure swLNG;
begin
  if(_lng)
  then lng_rus
  else lng_eng;
end;



