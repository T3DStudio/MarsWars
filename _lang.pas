

function GetKeyName(k:cardinal):shortstring;
begin
   case k of
SDL_BUTTON_left     : GetKeyName:='Mouse left button';
SDL_BUTTON_right    : GetKeyName:='Mouse right button';
SDL_BUTTON_middle   : GetKeyName:='Mouse middle button';
SDL_BUTTON_WHEELUP  : GetKeyName:='Mouse wheel up';
SDL_BUTTON_WHEELDOWN: GetKeyName:='Mouse wheel down';
   else GetKeyName  := sdl_getkeyname(k);
   end
end;

procedure _addStr(ps:pshortstring;s,p:shortstring);
begin
   if(ps^='')
   then ps^:=s
   else ps^:=ps^+p+s
end;

procedure reqadd(req:pshortstring;st:shortstring);
begin
   if(req^='')then
   begin
      req^:=#17+str_req+#25;
      req^:=req^+st;
   end
   else req^:=req^+', '+st;
end;

procedure _AddReqStr;
var u:byte;
  req:shortstring;
begin
   for u:=0 to 255 do
   begin
      with _tuids[u] do
      begin
         req:='';
         if(_ruid >0)then reqadd(@req,_tuids [_ruid]._uname);
         if(_rupgr>0)then reqadd(@req,_tupids[_ruid]._upname);
         _uhint:=_uhint+req;
      end;
      with _tupids[u] do
      begin
         req:='';
         _uphint:=_uphint+req;
      end;
      with _toids[u] do
      begin
         req:='';
         _ohint:=_ohint+req;
      end;
   end;
end;

procedure setUnitStr(uid:byte;nm,ds:shortstring);
begin
   with _tuids[uid] do
   begin
      _uname:=nm;
      _udesc:=ds;

      _uhint:=_uname;
      if(_ukeyc<>'')then _uhint:=_uhint+' ('+#18+_ukeyc+#25+')';

      _uhint:=_uhint+'  ['+#22+'T: '+#25+i2s(_ctime div vid_fps)+#19+'  E: '+#25+b2s(_renerg)+']'+#13+#22+_udesc+#25+#13;

      //rmana
   end;
end;


procedure SetOrderStr(oid:byte;sn,sd:shortstring);
begin
   with _toids[oid] do
   begin
      _oname := sn;
      _odesc := sd;

      _ohint := _oname;
      if(_okeyc<>'')then _ohint:=_ohint+' ('+#18+_okeyc+#25+')'+#13+#22+_odesc+#25+#13;
   end;
end;

procedure lng_eng;
begin
   str_atargets          := 'Targets: ';
   str_amappoint         := 'map point';
   str_aunit             := 'unit';
   str_aown              := '-own units';
   str_aalies            := '-own+allies';
   str_aenemies          := '-enemies';
   str_adamaged          := '-damaged';
   str_adead             := '-dead';
   str_aalive            := '-alive';
   str_abio              := '-biological';
   str_amechs            := '-buildings&mechs';
   str_abuilds           := '-buildings';
   str_anoadv            := '-no advanced';
   str_aauto             := '+auto';

   str_MMap              := 'MAP';
   str_MPlayers          := 'PLAYERS';
   str_MObjectives       := 'OBJECTIVES';
   str_menu_s1[ms1_sett] := 'SETTINGS';
   str_menu_s1[ms1_svld] := 'SAVE/LOAD';
   str_menu_s1[ms1_reps] := 'REPLAYS';
   str_menu_s2[ms2_camp] := 'CAMPAIGNS';
   str_menu_s2[ms2_scir] := 'SKIRMISH';
   str_menu_s2[ms2_mult] := 'MULTIPLAYER';
   str_reset[false]      := 'START';
   str_reset[true ]      := 'RESET';
   str_exit[false]       := 'EXIT';
   str_exit[true]        := 'BACK';
   str_m_liq             := 'Lakes:       ';
   str_m_siz             := 'Size:        ';
   str_m_obs             := 'Obstacles:   ';
   str_map               := 'Map:    ';
   str_players           := 'Players';
   str_mrandom           := 'Random map';
   str_sound             := 'SOUND';
   str_musicvol          := 'Music';
   str_soundvol          := 'Effects';
   str_video             := 'VIDEO';
   str_game              := 'GAME';
   str_resol             := 'Resolution';
   str_scrollspd         := 'Scroll speed';
   str_mousescrl         := 'Mouse scroll';
   str_fullscreen        := 'Windowed';
   str_plname            := 'Player name';
   str_lng[true]         := 'RUS';
   str_lng[false]        := 'ENG';
   str_maction           := 'Right click';
   str_race[r_random]    := #25+'RANDOM';
   str_race[r_hell  ]    := #16+'HELL'+#25;
   str_race[r_uac   ]    := #18+'UAC'+#25;
   str_win               := 'VICTORY!';
   str_lose              := 'DEFEAT!';
   str_pause             := 'Pause';
   str_gsaved            := 'Game saved';
   str_repend            := 'Replay ended!';
   str_save              := 'Save';
   str_load              := 'Load';
   str_delete            := 'Delete';
   str_svld_errors[1]    := 'File not'+#13+'exists!';
   str_svld_errors[2]    := 'Can`t open'+#13+'file!';
   str_svld_errors[3]    := 'Wrong file'+#13+'size!';
   str_svld_errors[4]    := 'Wrong version!';
   str_time              := 'Time: ';
   str_menu              := 'Menu';
   str_play              := 'Play';
   str_replay            := 'RECORD';
   str_waitsv            := 'Awaiting server...';
   str_goptions          := 'GAME OPTIONS';
   str_server            := 'SERVER';
   str_client            := 'CLIENT';
   str_chat              := 'CHAT';
   str_randoms           := 'Random skirmish';
   str_apply             := 'apply';
   str_plout             := ' left the game';
   str_tarchat[false]    := 'all';
   str_tarchat[true ]    := 'team';
   str_fileerr           := 'Error when reading file!';
   str_fileerw           := 'Error when writing file!';
   str_aislots           := 'Fill empty slots:';
   str_language          := 'UI language';
   str_selall            := 'Ctr+A F2';
   str_selallh           := 'Select all battle units ('+#18+str_selall+#25+')';
   str_builders          := 'Builders';
   str_uienerg           := 'Energy: current/maximum';
   str_uiarmy            := 'Army size';
   str_sstarts           := 'Show player positions:';
   str_uimana            := 'Mana';

   str_maction2[true ]   := #15+'Attack'+#25;
   str_maction2[false]   := #18+'Move'+#25;

   str_tabs[0]           := 'Buildings';
   str_tabs[1]           := 'Units';
   str_tabs[2]           := 'Researches';

   str_pnua[0]           := #19+'x1 '+#25+'/'+#15+'x1 ';
   str_pnua[1]           := #19+'x2 '+#25+'/'+#15+'x2 ';
   str_pnua[2]           := #18+'x3 '+#25+'/'+#16+'x3 ';
   str_pnua[3]           := #18+'x4 '+#25+'/'+#16+'x4 ';
   str_pnua[4]           := #17+'x5 '+#25+'/'+#17+'x5 ';
   str_pnua[5]           := #17+'x6 '+#25+'/'+#17+'x6 ';
   str_pnua[6]           := #16+'x7 '+#25+'/'+#18+'x7 ';
   str_pnua[7]           := #16+'x8 '+#25+'/'+#18+'x8 ';
   str_pnua[8]           := #15+'x9 '+#25+'/'+#19+'x9 ';
   str_pnua[9]           := #15+'x10'+#25+'/'+#19+'x10';

   str_npnua[0]          := #15+'x1 ';
   str_npnua[1]          := #15+'x2 ';
   str_npnua[2]          := #16+'x3 ';
   str_npnua[3]          := #16+'x4 ';
   str_npnua[4]          := #17+'x5 ';
   str_npnua[5]          := #17+'x6 ';
   str_npnua[6]          := #18+'x7 ';
   str_npnua[7]          := #18+'x8 ';
   str_npnua[8]          := #19+'x9 ';
   str_npnua[9]          := #19+'x10';

   str_gmodet            := 'Game mode:';
   str_gmode[0]          := #18+'Skirmish'+#25;
   str_gmode[1]          := #16+'Two bases'+#25;
   str_gmode[2]          := #17+'Three bases'+#25;

   str_team              := 'Team:';
   str_srace             := 'Race:';
   str_ready             := 'Ready: ';
   str_udpport           := 'UDP port:';
   str_svup[false]       := 'Start server';
   str_svup[true ]       := 'Stop server';
   str_connect[false]    := 'Connect';
   str_connect[true ]    := 'Disconnect';
   str_pnu               := 'File size / quality: ';
   str_npnu              := 'Units update rate: ';
   str_connecting        := 'Connecting...';
   str_sver              := 'Wrong version!';
   str_sfull             := 'Server full!';
   str_sgst              := 'Game started!';

   str_req               := 'Requirements: ';


   setUnitStr(UID_HKeep     ,'Hell Keep'     ,'Builds base.');
   setUnitStr(UID_HGate     ,'Hell Gate'     ,'Summons units.');
   setUnitStr(UID_HSymbol   ,'Hell Symbol'   ,'Generates energy.');
   setUnitStr(UID_HPools    ,'Hell Pools'    ,'Research upgrades.');
   setUnitStr(UID_HTower    ,'Hell Tower'    ,'Defensive structure.');
   setUnitStr(UID_HTeleport ,'Hell Teleport' ,'Teleports units to any place.');
   setUnitStr(UID_HMonastery,'Hell Monastery','Upgrades units.');
   setUnitStr(UID_HFortress ,'Hell Fortress' ,'Tier 2 buildings, units and upgrades.');
   setUnitStr(UID_HTotem    ,'Hell Totem'    ,'Advanced defensive structure.');
   setUnitStr(UID_HAltar    ,'Hell Altar'    ,'Support structure.');

   setUnitStr(UID_LostSoul   ,'Lost Soul'     ,'');
   setUnitStr(UID_Imp        ,'Imp'           ,'');
   setUnitStr(UID_Demon      ,'Demon'         ,'');
   setUnitStr(UID_Cacodemon  ,'Cacodemon'     ,'');
   setUnitStr(UID_Knight     ,'Hell Knight'   ,'');
   setUnitStr(UID_Cyberdemon ,'Cyberdemon'    ,'');
   setUnitStr(UID_Mastermind ,'Mastermind'    ,'');
   setUnitStr(UID_Pain       ,'Pain Elemental','');
   setUnitStr(UID_Revenant   ,'Revenant'      ,'');
   setUnitStr(UID_Mancubus   ,'Mancubus'      ,'');
   setUnitStr(UID_Arachnotron,'Arachnotron'   ,'');
   setUnitStr(UID_Archvile   ,'ArchVile'      ,'');

   setUnitStr(UID_UCommandCenter ,'UAC Command Center'         ,'Main building.');
   setUnitStr(UID_UMilitaryUnit  ,'UAC Military unit'          ,'Trains units.');
   setUnitStr(UID_UGenerator     ,'UAC Generator'              ,'Generates energy.');
   setUnitStr(UID_UWeaponFactory ,'UAC Weapon Factory'         ,'Research upgrades.');
   setUnitStr(UID_UTurret        ,'UAC Chaingun Turret'        ,'Defensive structure.');
   setUnitStr(UID_URadar         ,'UAC Radar'                  ,'Reveals map.');
   setUnitStr(UID_UVehicleFactory,'UAC Tech Center'            ,'Upgrades units.');
   setUnitStr(UID_UPTurret       ,'UAC Plasma turret'          ,'Defensive structure.');
   setUnitStr(UID_URocketL       ,'UAC Rocket Launcher Station','Provide a missile strike.');

   setUnitStr(UID_Dron       ,'UAC Dron'         ,'Builder. Can repair mechanical units.');
   setUnitStr(UID_Medic      ,'Medic'            ,'');
   setUnitStr(UID_Sergant    ,'Sergant'          ,'');
   setUnitStr(UID_Commando   ,'Commando'         ,'');
   setUnitStr(UID_Bomber     ,'Artillery soldier','');
   setUnitStr(UID_Major      ,'Major'            ,'');
   setUnitStr(UID_BFG        ,'BFG Marine'       ,'');
   setUnitStr(UID_FAPC       ,'Air APC'          ,'');
   setUnitStr(UID_APC        ,'Ground APC'       ,'');
   setUnitStr(UID_Terminator ,'UAC Terminator'   ,'');
   setUnitStr(UID_Tank       ,'UAC Tank'         ,'');
   setUnitStr(UID_Flyer      ,'UAC Fighter'      ,'');


   SetOrderStr(uo_move     ,'Move'  ,'');
   SetOrderStr(uo_attack   ,'Attack','Right click to switch auto target search.');
   SetOrderStr(uo_patrol   ,'Patrol','');
   SetOrderStr(uo_stop     ,'Stop'  ,'');
   SetOrderStr(uo_hold     ,'Hold position'      ,'');
   SetOrderStr(uo_upload   ,'Upload unit'        ,'');
   SetOrderStr(uo_unload   ,'Unload all units'   ,'');
   SetOrderStr(uo_rallpos  ,'Set rally-point'    ,'');
   SetOrderStr(uo_destroy  ,'Destroy'            ,'');
   SetOrderStr(uo_spawndron,'Create UAC Drone'   ,_tuids[UID_Dron]._udesc);
   SetOrderStr(uo_auto     ,'Switch auto mode'   ,'');


   _AddReqStr;


  {
  str_player_def        := ' was terminated!';
  str_inv_time          := 'Wave #';
  str_inv_ml            := 'Monsters: ';
  str_cmpdif            := 'Difficulty: ';

  str_cmpd[0]           := #19+'I`m too young to die'+#25;
  str_cmpd[1]           := #18+'Hey, not too rough'+#25;
  str_cmpd[2]           := #17+'Hurt me plenty'+#25;
  str_cmpd[3]           := #16+'Ultra-Violence'+#25;
  str_cmpd[4]           := #15+'Nightmare!'+#25;


   str_hint_m[0]         := 'Menu ('          +#18+'Esc'+#25+')';
   str_hint_m[2]         := 'Pause ('         +#18+'Pause/Break'+#25+')';

   _mkHStr(1,r_hell,upgr_attack  ,'Range attack upgrade'       ,'Increase ranged attacks damage.','');
   _mkHStr(1,r_hell,upgr_armor   ,'Unit armor upgrade'         ,'Increase units armor.','');
   _mkHStr(1,r_hell,upgr_build   ,'Buildinds armor upgrade'    ,'Increase buildings armor.','');
   _mkHStr(1,r_hell,upgr_melee   ,'Melee attack upgrade'       ,'Increase melee attacks damage.','');
   _mkHStr(1,r_hell,upgr_regen   ,'Regeneration'               ,'Units will slowly regenerate their health.','');
   _mkHStr(1,r_hell,upgr_paina   ,'Decay aura'                 ,'Hell Keep will damage all enemies around.','');
   _mkHStr(1,r_hell,upgr_vision  ,'Hell vision'                ,'Cyberdemon, Mastermind and Hell Symbol becomes detectors.','');
   _mkHStr(1,r_hell,upgr_pains   ,'Pain threshold'             ,'Decrease "pain state" chance.','');
   _mkHStr(1,r_hell,upgr_5bld    ,'Teleport upgrade'           ,'Decrease teleport cooldown.','');
   _mkHStr(1,r_hell,upgr_mainm   ,'Hell Keep teleportaion'     ,'Hell keep can teleport to any place.','');
   _mkHStr(1,r_hell,upgr_towers  ,'Tower range upgrade'        ,'Increased range of defensive structures.','');
   _mkHStr(1,r_hell,upgr_hsmbl   ,'','','');
   _mkHStr(1,r_hell,upgr_mainonr ,'Free teleportation'         ,'Hell Keep can teleport to anywhere.','');
   _mkHStr(1,r_hell,upgr_bldrep  ,'Building restoration'       ,'Hell altar ability.','');
   _mkHStr(1,r_hell,upgr_6bld    ,'Soul collector'             ,'Hell Monastery will be able to collect souls to upgrade units.','');
   _mkHStr(1,r_hell,upgr_2tier   ,'Ancient evil'               ,'Tier 2 buildings, units and upgrades.','');

   _mkHStr(1,r_hell,upgr_revtele ,'Reverse teleport'           ,'Units can teleport back to Hell Teleport.'         ,t2str);
   _mkHStr(1,r_hell,upgr_revmis  ,'Revenant missile upgrade'   ,'Increase attack range, missiles become homing.'    ,t2str);
   _mkHStr(1,r_hell,upgr_hpower  ,'Hell power'                 ,'Increase number of units affected by Hell altar.'  ,t2str);
   _mkHStr(1,r_hell,upgr_hsymbol ,'Hell Symbol upgrade'        ,'Increase Hell Symbol`s energy income.'             ,t2str);

   _mkHStr(1,r_hell,upgr_6bld2   ,'Soul storage'               ,'Hell Monastery can store more souls.'              ,t2str);

   _mkHStr(1,r_hell,upgr_b478tel ,'Symbols, Towers and Altars teleport ability'
                                                               ,'Hell Symbols, Towers, Totems and Altars can teleport to short distance.'
                                                                                                                    ,t2str);
   _mkHStr(1,r_hell,upgr_hinvuln ,'Temporary Invulnerability'  ,'All hell units become invulnerable for 15 seconds.',t2str);


   t2str:='Tech Center, "High technologies" research.';



   _mkHStr(1,r_uac ,upgr_attack  ,'Ranged attack upgrade'  ,'Increase damage of ranged attacks.','');
   _mkHStr(1,r_uac ,upgr_armor   ,'Infantry armor upgrade' ,'Increase infantry armor.','');
   _mkHStr(1,r_uac ,upgr_build   ,'Buildings armor upgrade','Increase buildings armor.','');
   _mkHStr(1,r_uac ,upgr_melee   ,'Repair and healing'     ,'Increase the efficiency of repair/healing of Engineers and Medics.','');
   _mkHStr(1,r_uac ,upgr_mspeed  ,'Lightweight armor'      ,'Increase infantry move speed.','');
   //_mkHStr(1,r_uac ,upgr_ucomatt ,'BFG turret'             ,'Command Center will be able to attack.'         ,t2str);
   //_mkHStr(1,r_uac ,upgr_shield  ,'Plasma shields'         ,'All buildings and mechs get plasma shields.','');
   _mkHStr(1,r_uac ,upgr_vision  ,'Detector device'        ,'Radar and mines becomes detectors.','');
   _mkHStr(1,r_uac ,upgr_invis   ,'Stealth troopers'       ,'Infantry becomes invisible.','');
   _mkHStr(1,r_uac ,upgr_5bld    ,'Radar upgrade'          ,'Increase radar scouting time and radius.','');
   _mkHStr(1,r_uac ,upgr_mainm   ,'Command Center flight'  ,'Command Center gains ability to fly.','');
   _mkHStr(1,r_uac ,upgr_towers  ,'Turrets range upgrade'  ,'Increased attack range of defensive structures.','');
   _mkHStr(1,r_uac ,upgr_mainr   ,'Command Center range'   ,'Increased Command Center view/build range.','');
   _mkHStr(1,r_uac ,upgr_mainonr ,'Free placement'         ,'Command center will be able to land anywhere.','');
   _mkHStr(1,r_uac ,upgr_6bld    ,'Advanced armory'        ,'Tech Center will be able to upgrade units.','');
   _mkHStr(1,r_uac ,upgr_2tier   ,'High technologies'      ,'Tier 2 buildings, units and upgrades.','');
   _mkHStr(1,r_uac ,upgr_blizz   ,'Missile strike'         ,'Missile strike from Rocket Launcher Station.'   ,t2str);
   _mkHStr(1,r_uac ,upgr_mechspd ,'Advanced engines'       ,'Increase mechs move speed.'                     ,t2str);
   _mkHStr(1,r_uac ,upgr_mecharm ,'Mech armor upgrade'     ,'Increase mechs armor.'                          ,t2str);
   _mkHStr(1,r_uac ,upgr_ucomatt ,'BFG turret'             ,'Command Center will be able to attack.'         ,t2str);
   _mkHStr(1,r_uac ,upgr_minesen ,'Mine-sensor'            ,'Mine ability.'                                  ,t2str);
   _mkHStr(1,r_uac ,upgr_6bld2   ,'Fast rearmament'        ,'Tech Center upgrades units faster.'             ,t2str);

   _mkHStr(1,r_uac ,upgr_addtur  ,'Additional turret'      ,'Additional weapon for UAC Turret.'              ,t2str);
   _mkHStr(1,r_uac ,upgr_apctur  ,'Turret for transport'   ,'Turret for APC.'                                ,t2str);


   str_hint[2,r_hell,0 ] := 'Faster game speed ('+#18+'Q'+#25+')';
   str_hint[2,r_hell,1 ] := 'Left click: skip 2 seconds ('+#18+'W'+#25+')'+#11+'Right click: skip 10 seconds ('+#18+'Ctrl'+#25+'+'+#18+'W'+#25+')';
   str_hint[2,r_hell,2 ] := 'List of game messages ('+#18+'E'+#25+')';
   str_hint[2,r_hell,3 ] := 'Fog of war ('+#18+'A'+#25+')';
   str_hint[2,r_hell,6 ] := 'All players ('+#18+'Z'+#25+')';
   str_hint[2,r_hell,7 ] := 'Red player [#1] ('+#18+'X'+#25+')';
   str_hint[2,r_hell,8 ] := 'Yellow player [#2] ('+#18+'C'+#25+')';
   str_hint[2,r_hell,9 ] := 'Green player [#3] ('+#18+'R'+#25+')';
   str_hint[2,r_hell,10] := 'Blue player [#4] ('+#18+'T'+#25+')';
   str_hint[2,r_uac ,0 ] := str_hint[2,r_hell,0 ];
   str_hint[2,r_uac ,1 ] := str_hint[2,r_hell,1 ];
   str_hint[2,r_uac ,2 ] := str_hint[2,r_hell,2 ];
   str_hint[2,r_uac ,3 ] := str_hint[2,r_hell,3 ];
   str_hint[2,r_uac ,6 ] := str_hint[2,r_hell,6 ];
   str_hint[2,r_uac ,7 ] := str_hint[2,r_hell,7 ];
   str_hint[2,r_uac ,8 ] := str_hint[2,r_hell,8 ];
   str_hint[2,r_uac ,9 ] := str_hint[2,r_hell,9 ];
   str_hint[2,r_uac ,10] := str_hint[2,r_hell,10];

   str_hint[0,r_uac ,25] := 'Mines';
   str_hint[1,r_uac ,25] := str_hint[0,r_uac ,25];
   str_hint[0,r_hell,25] := 'Zombie ('+#18+'M'+#25+')';
   str_hint[1,r_hell,25] := str_hint[0,r_hell,25];

   str_hint[0,r_uac ,21] := 'Action ('        +#18+'Ctrl'+#25+'+'+#18+'Space'+#25+')';
   str_hint[0,r_uac ,22] := 'Destroy ('       +#18+'Delete'+#25+')';
   str_hint[0,r_uac ,23] := 'Cancle ('        +#18+'Space'+#25+')';
   str_hint[1,r_uac ,24] := 'Menu ('          +#18+'Esc'+#25+')';
   str_hint[0,r_hell,21] := str_hint[0,r_uac ,21];
   str_hint[0,r_hell,22] := str_hint[0,r_uac ,22];
   str_hint[0,r_hell,23] := str_hint[0,r_uac ,23];
   str_hint[0,r_hell,24] := str_hint[0,r_uac ,24];
   str_hint[1,r_hell,24] := str_hint[1,r_uac ,24];}
end;

procedure lng_rus;
begin
   str_atargets          := '����: ';
   str_amappoint         := '����� �� �����';
   str_aunit             := '����';
   str_aown              := '-����';
   str_aalies            := '-����+�������';
   str_aenemies          := '-����';
   str_adamaged          := '-������������';
   str_adead             := '-�������';
   str_aalive            := '-�����';
   str_abio              := '-�������������';
   str_amechs            := '-�������+������';
   str_abuilds           := '-������ ������';
   str_anoadv            := '-�� ���������';
   str_aauto             := '+����';

   str_MMap              := '�����';
   str_MPlayers          := '������';
   str_MObjectives       := '������';
   str_menu_s1[ms1_sett] := '���������';
   str_menu_s1[ms1_svld] := '����./����.';
   str_menu_s1[ms1_reps] := '������';
   str_menu_s2[ms2_camp] := '��������';
   str_menu_s2[ms2_scir] := '�������';
   str_menu_s2[ms2_mult] := '������� ����';
   str_reset[false]      := '������';
   str_reset[true ]      := '�����';
   str_exit[false]       := '�����';
   str_exit[true]        := '�����';
   str_m_liq             := '�����:       ';
   str_m_siz             := '������:      ';
   str_m_obs             := '��������:    ';
   str_map               := '�����:  ';
   str_players           := '������';
   str_mrandom           := '��������� �����';
   str_sound             := '����';
   str_musicvol          := '������';
   str_soundvol          := '�������';
   str_video             := '�����';
   str_game              := '����';
   str_resol             := '����������';
   str_scrollspd         := '�������� ������';
   str_mousescrl         := '����������� ������ �����';
   str_fullscreen        := '� ����';
   str_plname            := '��� ������';
   str_maction           := '������ ����';
   str_pause             := '�����';
   str_win               := '������!';
   str_lose              := '���������!';
   str_gsaved            := '���� ���������';
   str_repend            := '����� ������!';
   str_save              := '���������';
   str_load              := '���������';
   str_delete            := '�������';
   str_svld_errors[1]    := '���� ��'+#13+'����������!';
   str_svld_errors[2]    := '����������'+#13+'������� ����!';
   str_svld_errors[3]    := '������������'+#13+'������ �����!';
   str_svld_errors[4]    := '������������'+#13+'������ �����!';
   str_time              := '�����: ';
   str_menu              := '����';
   str_play              := '���������';
   str_replay            := '������';
   str_waitsv            := '�������� �������...';
   str_goptions          := '��������� ����';
   str_server            := '������';
   str_client            := '������';
   str_chat              := '���';
   str_randoms           := '��������� �������';
   str_apply             := '���������';
   str_plout             := ' ������� ����';
   str_tarchat[false]    := '����';
   str_tarchat[true ]    := '�����';
   str_fileerr           := '������ ��� ������ �����!';
   str_fileerw           := '������ ��� ������ �����!';
   str_aislots           := '��������� ������ �����:';
   str_language          := '���� ����������';
   str_selallh           := '������� ���� ������ ������ ('+#18+str_selall+#25+')';
   str_builders          := '���������';
   str_uienerg           := '�������: �������/������������';
   str_uiarmy            := '������ �����';
   str_sstarts           := '�������� ������� �������:';
   str_uimana            := '����';

   str_maction2[true ]   := #15+'�����'+#25;
   str_maction2[false]   := #18+'��������'+#25;

   str_tabs[0]           := '������';
   str_tabs[1]           := '������';
   str_tabs[2]           := '������������';

   str_gmodet            := '����� ����:';
   str_gmode[0]          := #18+'�������'+#25;
   str_gmode[1]          := #16+'��� ��������'+#25;
   str_gmode[2]          := #17+'��� ��������'+#25;

   str_team              := '����:';
   str_srace             := '����:';
   str_ready             := '�����: ';
   str_udpport           := 'UDP ����:';
   str_svup[false]       := '���. ������';
   str_svup[true ]       := '����. ������';
   str_connect[false]    := '�����������';
   str_connect[true ]    := '����.';
   str_pnu               := '������ ����� / ��������: ';
   str_npnu              := '���������� ������: ';
   str_connecting        := '����������...';
   str_sver              := '������ ������!';
   str_sfull             := '��� ����!';
   str_sgst              := '���� ��������!';

   str_req               := '����������: ';


   setUnitStr(UID_HKeep     ,'������ �����'    ,'������ ����.');
   setUnitStr(UID_HGate     ,'������ �����'    ,'��������� �����.');
   setUnitStr(UID_HSymbol   ,'������ ������'   ,'���������� �������.');
   setUnitStr(UID_HPools    ,'������ �����'    ,'��������� ���������.');
   setUnitStr(UID_HTower    ,'������ �����'    ,'�������� ����������.');
   setUnitStr(UID_HTeleport ,'������ ��������' ,'���������� ������ � ����� ����� �����.');
   setUnitStr(UID_HMonastery,'������ ���������','�������� ������.');
   setUnitStr(UID_HFortress ,'������ ��������' ,'������ ������� ������, ������ � ���������.');
   setUnitStr(UID_HTotem    ,'������ �����'    ,'����������� �������� ����������.');
   setUnitStr(UID_HAltar    ,'������ ������'   ,'����������� �� ������ �������� �������.');

{   setUnitStr(UID_LostSoul   ,'Lost Soul'     ,'');
   setUnitStr(UID_Imp        ,'Imp'           ,'');
   setUnitStr(UID_Demon      ,'Demon'         ,'');
   setUnitStr(UID_Cacodemon  ,'Cacodemon'     ,'');
   setUnitStr(UID_Baron      ,'Hell Knight'   ,'');
   setUnitStr(UID_Cyberdemon ,'Cyberdemon'    ,'');
   setUnitStr(UID_Mastermind ,'Mastermind'    ,'');
   setUnitStr(UID_Pain       ,'Pain Elemental','');
   setUnitStr(UID_Revenant   ,'Revenant'      ,'');
   setUnitStr(UID_Mancubus   ,'Mancubus'      ,'');
   setUnitStr(UID_Arachnotron,'Arachnotron'   ,'');
   setUnitStr(UID_Archvile   ,'ArchVile'      ,'');  }

   setUnitStr(UID_UCommandCenter ,'��������� �����'         ,'���������� ������.');
   setUnitStr(UID_UMilitaryUnit  ,'��������� �����'         ,'��������� ������.');
   setUnitStr(UID_UGenerator     ,'���������'               ,'���������� �������.');
   setUnitStr(UID_UWeaponFactory ,'����� ����������'        ,'��������� ���������.');
   setUnitStr(UID_UTurret        ,'���������� ������'       ,'�������� ����������.');
   setUnitStr(UID_URadar         ,'�����'                   ,'����������� �����.');
   setUnitStr(UID_UVehicleFactory,'����������� �����'       ,'�������� ������.');
   setUnitStr(UID_UPTurret       ,'���������� ������'       ,'�������� ����������.');
   setUnitStr(UID_URocketL       ,'������� ��������� �����' ,'���������� �������� ����.');

   setUnitStr(UID_Dron       ,'����'               ,'������ � ����� ������.');
   setUnitStr(UID_Medic      ,'�����'              ,'');
   setUnitStr(UID_Sergant    ,'�������'            ,'');
   setUnitStr(UID_Commando   ,'��������'           ,'');
   setUnitStr(UID_Bomber     ,'�������������'      ,'');
   setUnitStr(UID_Major      ,'�����'              ,'');
   setUnitStr(UID_BFG        ,'������ � BFG'       ,'');
   setUnitStr(UID_FAPC       ,'��������� ���������','');
   setUnitStr(UID_APC        ,'���'                ,'');
   setUnitStr(UID_Terminator ,'����������'         ,'');
   setUnitStr(UID_Tank       ,'����'               ,'');
   setUnitStr(UID_Flyer      ,'�����������'        ,'');


   SetOrderStr(uo_move     ,'���������'     ,'');
   SetOrderStr(uo_attack   ,'���������'     ,'������ ���� - ����������� �������������� ����� ����.');
   SetOrderStr(uo_patrol   ,'�������������' ,'');
   SetOrderStr(uo_stop     ,'����'          ,'');
   SetOrderStr(uo_hold     ,'���������� �������'    ,'');
   SetOrderStr(uo_upload   ,'��������� ����'        ,'');
   SetOrderStr(uo_unload   ,'��������� ����'        ,'');
   SetOrderStr(uo_rallpos  ,'��������� ����� �����' ,'');
   SetOrderStr(uo_destroy  ,'Destroy'               ,'');
   SetOrderStr(uo_spawndron,'������� �����'         ,_tuids[UID_Dron]._udesc);
   SetOrderStr(uo_auto     ,'Switch auto mode'      ,'');

   _AddReqStr;

{
str_player_def        := ' ���������!';
str_inv_time          := '����� #';
str_inv_ml            := '�������: ';
str_cmpdif            := '���������: ';

  str_hint_m[0]         := '���� ('          +#18+'Esc'+#25+')';
  str_hint_m[2]         := '����� ('         +#18+'Pause/Break'+#25+')';



{  _mkHStr(1,r_hell,upgr_attack  ,'��������� ������� �����'        ,'���������� ����� ������� �����.','');
  _mkHStr(1,r_hell,upgr_armor   ,'��������� ������ ������'        ,'���������� ������ ������.','');
  _mkHStr(1,r_hell,upgr_build   ,'��������� ������ ������'        ,'���������� ������ ������.','');
  _mkHStr(1,r_hell,upgr_melee   ,'��������� ������� �����'        ,'���������� ����� ������� �����.','');
  _mkHStr(1,r_hell,upgr_regen   ,'�����������'                    ,'����� �������� ��������������� ���� ��������.','');
  _mkHStr(1,r_hell,upgr_paina   ,'���� ����������'                ,'������ �������� ������� ���� ���� ������ ������.','');
  _mkHStr(1,r_hell,upgr_vision  ,'������ ������'                  ,'Cyberdemon, Mastermind � ������ ������ ���������� �����������.','');
  _mkHStr(1,r_hell,upgr_pains   ,'������� �����'                  ,'��������� ���� "pain state".','');
  _mkHStr(1,r_hell,upgr_5bld    ,'��������� ���������'            ,'��������� ����� ����������� ���������.','');
  _mkHStr(1,r_hell,upgr_mainm   ,'������������ ������ ��������'   ,'������ �������� ����� ������������ � ����� ��������� ����� �����.','');
  _mkHStr(1,r_hell,upgr_towers  ,'������ ����� �����'             ,'���������� ������� ����� �������� ����������.','');

  //_mkHStr(1,r_hell,upgr_mainr   ,'������ ������ ������ ��������'  ,'����������� ������ ������ ������ ��������.','');
  _mkHStr(1,r_hell,upgr_6bld    ,'������� ���'                    ,'������ ��������� ����� �������� ������.','');
  _mkHStr(1,r_hell,upgr_2tier   ,'������� ���'                    ,'','');
  _mkHStr(1,r_hell,upgr_revtele ,'�������� ��������'              ,'����� ���� ������������ � ������ ��������.'                       ,t2str);
  _mkHStr(1,r_hell,upgr_revmis  ,'��������� ����� ����� Revenant' ,'���������� ��������� �����, ������� ����������� ����������������.',t2str);
  _mkHStr(1,r_hell,upgr_hpower  ,'������ ����'                    ,'��������� ����������� ������� ������.'                            ,t2str);
  _mkHStr(1,r_hell,upgr_hsymbol ,'��������� ������� �������'      ,'+1 � ������� ��� ������� ������� �������.'                        ,t2str);
  _mkHStr(1,r_hell,upgr_bldrep  ,'�������������� ������'          ,'����������� ������� ������.'                                      ,t2str);
  _mkHStr(1,r_hell,upgr_6bld2   ,'��������� ��� '                 ,'������ ��������� ����� ������� ������ ���.'                       ,t2str);
  _mkHStr(1,r_hell,upgr_mainonr ,'��������� ������������'         ,'������ �������� ����� ������������ �� �����, ����� � ��. �����������.',t2str);
  _mkHStr(1,r_hell,upgr_b478tel ,'������������ ��������, ����� � �������'
                                                                  ,'������ �������, �����, ������ � ������ ����� ����������������� �� �������� ����������.',t2str);
  _mkHStr(1,r_hell,upgr_hinvuln ,'��������� ������������'         ,'��� ����� ���������� ����������� �� 15 ������.'                   ,t2str);   }

  t2str:='����������� �����, ������������ "������� ����������".';


 { _mkHStr(1,r_uac ,upgr_attack  ,'��������� ������� �����'  ,'���������� ����� ������� �����.','');
  _mkHStr(1,r_uac ,upgr_armor   ,'��������� ������ ������'  ,'���������� ������ ������.','');
  _mkHStr(1,r_uac ,upgr_build   ,'��������� ������ ������'  ,'���������� ������ ������.','');
  _mkHStr(1,r_uac ,upgr_melee   ,'������ � �������'         ,'���������� ������������� �������/������� ��������/������.','');
  _mkHStr(1,r_uac ,upgr_mspeed  ,'����������� �����'        ,'���������� �������� ������������ ������.','');
//  _mkHStr(1,r_uac ,upgr_shield  ,'���������� ����'          ,'��� ������ � ������� �������� ���������� ����.','');
  _mkHStr(1,r_uac ,upgr_vision  ,'���������'                ,'����� � ���� ���������� �����������.','');
  _mkHStr(1,r_uac ,upgr_invis   ,'��������� ������'         ,'������ ���������� ���������.','');
  _mkHStr(1,r_uac ,upgr_5bld    ,'��������� ������'         ,'������������ ������ � ����� �������� ������.','');
  _mkHStr(1,r_uac ,upgr_mainm   ,'����� ���������� ������'  ,'��������� ����� ����� ������.','');
  _mkHStr(1,r_uac ,upgr_towers  ,'������ ����� �������'     ,'���������� ������� ����� �������� ����������.','');
  _mkHStr(1,r_uac ,upgr_mainr   ,'������ ������ ���������� ������','����������� ������ ������ ���������� ������.','');
  _mkHStr(1,r_uac ,upgr_6bld    ,'�������������� ����������','����������� ����� ����� �������� ������.','');
  _mkHStr(1,r_uac ,upgr_2tier   ,'������ ����������'        ,'������ ������� ������, ������ � ���������.','');
  _mkHStr(1,r_uac ,upgr_blizz   ,'�������� ����'            ,'������ ��� ������� ��������� �����.'                    ,t2str);
  _mkHStr(1,r_uac ,upgr_mechspd ,'����������� ���������'    ,'����������� �������� ������������ �������.'             ,t2str);
  _mkHStr(1,r_uac ,upgr_mecharm ,'��������� ������ �������' ,'���������� ������ �������.'                             ,t2str);
  _mkHStr(1,r_uac ,upgr_ucomatt ,'BFG ������'               ,'��������� ����� ����� ���������.'                       ,t2str);
  _mkHStr(1,r_uac ,upgr_minesen ,'����-������'              ,'����������� ����.'                                      ,t2str);
  _mkHStr(1,r_uac ,upgr_6bld2   ,'������� ��������������'   ,'����������� ����� ������� �������� ������.'             ,t2str);
  _mkHStr(1,r_uac ,upgr_mainonr ,'��������� �����������'    ,'��������� ����� ����� ������������ �� �����, ����� � ��. �����������.'  ,t2str);
  _mkHStr(1,r_uac ,upgr_addtur  ,'�������������� ������'    ,'�������������� ������ ��� ������.'                      ,t2str);
  _mkHStr(1,r_uac ,upgr_apctur  ,'������ ��� ����������'    ,''                                                       ,t2str);   }

  str_hint[2,r_hell,0 ] := '��������/��������� ���������� �������� ('+#18+'Q'+#25+')';
  str_hint[2,r_hell,1 ] := '����� ����: ���������� 2 ������� ('+#18+'W'+#25+')'+#11+'������ ����: ���������� 10 ������ ('+#18+'Ctrl'+#25+'+'+#18+'W'+#25+')';
  str_hint[2,r_hell,2 ] := '������ ������� ��������� ('+#18+'E'+#25+')';
  str_hint[2,r_hell,3 ] := '����� ����� ('+#18+'A'+#25+')';
  str_hint[2,r_hell,6 ] := '��� ������ (' +#18+'Z'+#25+')';
  str_hint[2,r_hell,7 ] := '������� ����� [#1] ('+#18+'X'+#25+')';
  str_hint[2,r_hell,8 ] := '������ ����� [#2] (' +#18+'C'+#25+')';
  str_hint[2,r_hell,9 ] := '������� ����� [#3] ('+#18+'R'+#25+')';
  str_hint[2,r_hell,10] := '����� ����� [#4] ('  +#18+'T'+#25+')';
  str_hint[2,r_uac ,0 ] := str_hint[2,r_hell,0 ];
  str_hint[2,r_uac ,1 ] := str_hint[2,r_hell,1 ];
  str_hint[2,r_uac ,2 ] := str_hint[2,r_hell,2 ];
  str_hint[2,r_uac ,3 ] := str_hint[2,r_hell,3 ];
  str_hint[2,r_uac ,6 ] := str_hint[2,r_hell,6 ];
  str_hint[2,r_uac ,7 ] := str_hint[2,r_hell,7 ];
  str_hint[2,r_uac ,8 ] := str_hint[2,r_hell,8 ];
  str_hint[2,r_uac ,9 ] := str_hint[2,r_hell,9 ];
  str_hint[2,r_uac ,10] := str_hint[2,r_hell,10];

  str_hint[0,r_uac ,25] := '����';
  str_hint[1,r_uac ,25] := str_hint[0,r_uac ,25];
  str_hint[0,r_hell,25] := '����� ('+#18+'M'+#25+')';
  str_hint[1,r_hell,25] := str_hint[0,r_hell,25];

  str_hint[0,r_hell,21] := '�������� ('      +#18+'Ctrl'+#25+'+'+#18+'Space'+#25+')';
  str_hint[0,r_hell,22] := '���������� ('    +#18+'Delete'+#25+')';
  str_hint[0,r_hell,23] := '������ ('        +#18+'Space'+#25+')';
  str_hint[1,r_hell,24] := '���� ('          +#18+'Esc'+#25+')';
  str_hint[0,r_uac ,21] := str_hint[0,r_hell,21];
  str_hint[0,r_uac ,22] := str_hint[0,r_hell,22];
  str_hint[0,r_uac ,23] := str_hint[0,r_hell,23];
  str_hint[0,r_uac ,24] := str_hint[0,r_hell,24];
  str_hint[1,r_uac ,24] := str_hint[1,r_hell,24]; }
end;

procedure swLNG;
begin
  if(_lng)
  then lng_rus
  else lng_eng;
end;




