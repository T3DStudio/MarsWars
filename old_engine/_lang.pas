procedure _mkHStrXY(tab,i,x,y:byte;STR:string);
begin
   if(i=255)then i:=(y div 3)+x;
   if(i>_uts)then exit;
   str_hint[tab,r_hell,i ] := STR;
   str_hint[tab,r_uac ,i ] := str_hint[tab,r_hell,i ];
end;

procedure _mkHStrUid(uid:byte;NAME,DESCR:string);
begin
   str_un_name [uid]:=NAME;
   str_un_descr[uid]:=DESCR;
end;

procedure _mkHStrUpid(race,upid:byte;NAME,DESCR:string);
begin
   str_up_name [upid+(_uts*race)]:=NAME;
   str_up_descr[upid+(_uts*race)]:=DESCR;
end;

function _gHK(tab,ucl:byte):shortstring;
const hot_keys : array[0..15] of char = ('R','T','Y','F','G','H','V','B','N','U','I','O','J','K','L','M');
begin
   _gHK:='';
   case tab of
   0  : if(ucl<18)then
         if(ucl<9)
         then _gHK:=#18+hot_keys[ucl]+#25
         else _gHK:=#18+'Ctrl'+#25+'+'+#18+hot_keys[ucl-9]+#25;
   1  : if(ucl<24)then
         if(ucl<9)
         then _gHK:=#18+hot_keys[ucl]+#25
         else
           if(ucl<18)
           then _gHK:=#18+'Ctrl'+#25+'+'+#18+hot_keys[ucl-9]+#25
           else _gHK:=#18+hot_keys[ucl-9]+#25;
   2  : if(ucl<26)then
         if(ucl<15)
         then _gHK:=#18+hot_keys[ucl]+#25
         else _gHK:=#18+'Ctrl'+#25+'+'+#18+hot_keys[ucl-15]+#25 ;
   end;
end;

function _uid2HK(uid:byte):shortstring;
begin
   with _ulst[uid] do
   begin
      if(isbuild)
      then _uid2HK:=_gHK(0,ucl)
      else _uid2HK:=_gHK(1,ucl);
   end;
end;

procedure _makeHints;
var rc,
ucl,uid       :byte;
  ENRG,NAME,HK,
DESCR,TIME,REQ:shortstring;
begin
   for uid:=0 to 255 do
   begin
      REQ  :='';
      NAME :=str_un_name [uid];
      if(NAME='')then continue;
      DESCR:=str_un_descr[uid];
      with _ulst[uid] do
      begin
         if(renerg>0)
         then ENRG:=b2s(renerg)
         else ENRG:='';
         case isbuild of
         true :if(bld_s>0)
               then TIME:=i2s(mhits div bld_s div 2)
               else TIME:='';
         false:if(trt>0)
               then TIME:=i2s(trt div vid_fps)
               else TIME:='';
         end;
         if(ruid <255)then REQ:=str_un_name[ruid];
         if(rupgr<255)then
         begin
            if(REQ<>'')then REQ:=REQ+', ';
            rc:=0;
            if(uid in uids_hell)then rc:=r_hell;
            if(uid in uids_uac )then rc:=r_uac;
            if(rc in [r_hell,r_uac])
            then REQ:=REQ+str_up_name[rupgr+(_uts*rc)]
            else REQ:=REQ+'#'+b2s(rupgr);
         end;
      end;
      str_un_hint[uid]:= NAME;
      HK:=_uid2HK(uid);
      if(HK  <>'')then str_un_hint[uid]:=str_un_hint[uid]+' ('+HK+')';
      if(TIME<>'')then str_un_hint[uid]:=str_un_hint[uid]+' ['+#16+TIME+#25+']';
      if(ENRG<>'')then str_un_hint[uid]:=str_un_hint[uid]+' {'+#19+ENRG+#25+'}';
      str_un_hint[uid]:=str_un_hint[uid]+#11+DESCR+#11;
      if(REQ<>'')then str_un_hint[uid]:= str_un_hint[uid]+#17+str_req+#25+REQ;
   end;

   for rc:=1 to 2 do
   for ucl:=0 to _uts do
   begin
      REQ  :='';
      uid  :=ucl+(_uts*rc);
      NAME :=str_up_name [uid];
      DESCR:=str_up_descr[uid];
      if(NAME='')then continue;

      enrg :=b2s(_pne_r[rc,ucl]);
      TIME :=i2s(upgrade_time[rc ,ucl] div vid_fps);

      if(upgrade_ruid [rc,ucl]<255)then REQ:=str_un_name[upgrade_ruid[rc,ucl]];
      if(upgrade_rupgr[rc,ucl]<255)then
      begin
         if(REQ<>'')then REQ:=REQ+', ';
         REQ:=REQ+str_up_name[upgrade_rupgr[rc,ucl]+(_uts*rc)];
      end;

      str_up_hint[uid]:=NAME+' ('+_gHK(2,ucl)+') ['+#16+TIME+#25+'] '+'{'+#19+enrg+#25+'}'+' x'+#17+b2s(upgrade_cnt[rc ,ucl ])+#25;
      if(ucl in upgr_1[rc])then str_up_hint[uid]:= str_up_hint[uid]+#15+' *'+#25;

      str_up_hint[uid]:=str_up_hint[uid]+#11+DESCR+#11;
      if(REQ<>'')then str_up_hint[uid]:=str_up_hint[uid]+#17+str_req+#25+REQ;
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
   str_maction           := 'Right click';
   str_maction2[true ]   := #18+'Move'+#25;
   str_maction2[false]   := #17+'Move'+#25+'+'+#17+'attack'+#25;
   str_race[r_random]    := #25+'RANDOM'+#25;
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
   str_gaddon            := 'Game:';
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

   str_starta            := 'Starting base:';
   str_startat[0]        := '1 '+#19+'builder'+#25;
   str_startat[1]        := '1 '+#19+'builder'+#25+'+ 1 '+#18+'gen.'+#25;
   str_startat[2]        := '1 '+#19+'builder'+#25+'+ 2 '+#18+'gen.'+#25;
   str_startat[3]        := '1 '+#19+'b.'+#25+'+ 2 '+#18+'gen.'+#25+'+ 2 '+#17+'b.'+#25;
   str_startat[4]        := '2 '+#19+'builders'+#25;
   str_startat[5]        := '1 '+#19+'b.'+#25+'+ 100 energy';

   str_sstarts           := 'Show player starts:';

   str_pnua[0]           := #19+'x1 '+#25+'/'+#15+' x1';
   str_pnua[1]           := #19+'x2 '+#25+'/'+#15+' x2';
   str_pnua[2]           := #18+'x3 '+#25+'/'+#16+' x3';
   str_pnua[3]           := #18+'x4 '+#25+'/'+#16+' x4';
   str_pnua[4]           := #17+'x5 '+#25+'/'+#17+' x5';
   str_pnua[5]           := #17+'x6 '+#25+'/'+#17+' x6';
   str_pnua[6]           := #16+'x7 '+#25+'/'+#18+' x7';
   str_pnua[7]           := #16+'x8 '+#25+'/'+#18+' x8';
   str_pnua[8]           := #15+'x9 '+#25+'/'+#19+' x9';
   str_pnua[9]           := #15+'x10'+#25+'/'+#19+' x10';

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

   str_cmpd[0]           := #20+'I`m too young to die'+#25;
   str_cmpd[1]           := #19+'Hey, not too rough'+#25;
   str_cmpd[2]           := #18+'Hurt me plenty'+#25;
   str_cmpd[3]           := #17+'Ultra-Violence'+#25;
   str_cmpd[4]           := #16+'Unholy massacre'+#25;
   str_cmpd[5]           := #15+'Nightmare'+#25;
   str_cmpd[6]           := #14+'HELL'+#25;

   str_gmodet            := 'Game mode:';
   str_gmode[gm_scir ]   := #18+'Skirmish'+#25;
   str_gmode[gm_2fort]   := #16+'Two bases'+#25;
   str_gmode[gm_3fort]   := #17+'Three bases'+#25;
   str_gmode[gm_ct   ]   := #19+'Capturing points'+#25;
   str_gmode[gm_inv  ]   := #20+'Invasion'+#25;
   str_gmode[gm_coop ]   := #15+'Assault'+#25;

   str_addon[false]      := #16+'UDOOM'+#25;
   str_addon[true ]      := #18+'DOOM 2'+#25;

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

   str_hint_a[0]         := 'Energy ('+#19+'free'+#25+'/max)';
   str_hint_a[1]         := 'Army (unit+buildings)';

   str_hint_m[0]         := 'Menu (' +#18+'Esc'+#25+')';
   str_hint_m[2]         := 'Pause ('+#18+'Pause/Break'+#25+')';


   _mkHStrUid(UID_HKeep        ,'Hell Keep'         ,'Builds base.'                 );
   _mkHStrUid(UID_HGate        ,'Hell Gate'         ,'Summons units.'               );
   _mkHStrUid(UID_HSymbol      ,'Hell Symbol'       ,'Generates energy.'            );
   _mkHStrUid(UID_HPools       ,'Hell Pools'        ,'Research upgrades.'           );
   _mkHStrUid(UID_HTower       ,'Hell Tower'        ,'Defensive structure.'         );
   _mkHStrUid(UID_HTeleport    ,'Hell Teleport'     ,'Teleports units to any place.');
   _mkHStrUid(UID_HMonastery   ,'Hell Monastery'    ,'Upgrades units.'                    );
   _mkHStrUid(UID_HTotem       ,'Hell Totem'        ,'Advanced defensive structure.'      );
   _mkHStrUid(UID_HAltar       ,'Hell Altar'        ,'Casts "Invulnerability" on units.'  );
   _mkHStrUid(UID_HFortress    ,'Hell Fortress'     ,'');
   _mkHStrUid(UID_HMilitaryUnit,'Hell Military Unit','Corrupted UAC Military Unit.');
   _mkHStrUid(UID_HEye         ,'Hell Eye'          ,'');

   _mkHStrUid(UID_LostSoul   ,'Lost Soul'      ,'');
   _mkHStrUid(UID_Imp        ,'Imp'            ,'');
   _mkHStrUid(UID_Demon      ,'Demon'          ,'');
   _mkHStrUid(UID_Cacodemon  ,'Cacodemon'      ,'');
   _mkHStrUid(UID_Baron      ,'Baron of Hell / Hell Knight','');
   _mkHStrUid(UID_Cyberdemon ,'Cyberdemon'     ,'');
   _mkHStrUid(UID_Mastermind ,'Mastermind'     ,'');
   _mkHStrUid(UID_Pain       ,'Pain Elemental' ,'');
   _mkHStrUid(UID_Revenant   ,'Revenant'       ,'');
   _mkHStrUid(UID_Mancubus   ,'Mancubus'       ,'');
   _mkHStrUid(UID_Arachnotron,'Arachnotron'    ,'');
   _mkHStrUid(UID_Archvile   ,'ArchVile'       ,'');
   _mkHStrUid(UID_ZFormer    ,'Zombie Former'  ,'');
   _mkHStrUid(UID_ZEngineer  ,'Zombie Engineer','');
   _mkHStrUid(UID_ZSergant   ,'Zombie Sergeant','');
   _mkHStrUid(UID_ZCommando  ,'Zombie Commando','');
   _mkHStrUid(UID_ZBomber    ,'Zombie Bomber'  ,'');
   _mkHStrUid(UID_ZMajor     ,'Zombie Major'   ,'');
   _mkHStrUid(UID_ZBFG       ,'Zombie BFG'     ,'');

   _mkHStrUpid(r_hell,upgr_attack  ,'Range attack upgrade'       ,'Increase ranged attacks damage.'                                           );
   _mkHStrUpid(r_hell,upgr_armor   ,'Unit armor upgrade'         ,'Increase units armor.'                                                     );
   _mkHStrUpid(r_hell,upgr_build   ,'Buildinds armor upgrade'    ,'Increase buildings armor.'                                                 );
   _mkHStrUpid(r_hell,upgr_melee   ,'Melee attack upgrade'       ,'Increase melee attacks damage.'                                            );
   _mkHStrUpid(r_hell,upgr_regen   ,'Regeneration'               ,'Damaged units will slowly regenerate their health.'                        );
   _mkHStrUpid(r_hell,upgr_pains   ,'Pain threshold'             ,'Decrease "pain state" chance.'                                             );
   _mkHStrUpid(r_hell,upgr_vision  ,'Hell eye'                   ,'Lost Soul ability & Hell Eye sight radius.'                                );
   _mkHStrUpid(r_hell,upgr_towers  ,'Tower range upgrade'        ,'Increased range of defensive structures.'                                  );
   _mkHStrUpid(r_hell,upgr_5bld    ,'Teleport upgrade'           ,'Decrease teleport cooldown.'                                               );
   _mkHStrUpid(r_hell,upgr_mainm   ,'Hell Keep teleportaion'     ,'Hell keep can teleport to any place.'                                      );
   _mkHStrUpid(r_hell,upgr_paina   ,'Decay aura'                 ,'Hell Keep will damage all enemies around.'                                 );
   _mkHStrUpid(r_hell,upgr_mainr   ,'Hell Keep range upgrade'    ,'Increased Hell Keep view/build range.'                                     );
   _mkHStrUpid(r_hell,upgr_pinkspd ,'Demon`s anger'              ,'Increased Demon`s speed.'                                                  );
   _mkHStrUpid(r_hell,upgr_misfst  ,'Firepower'                  ,'Increase missiles speed for Imp, Cacodemon and Baron of Hell/Hell Knight.' );
   _mkHStrUpid(r_hell,upgr_6bld    ,'Hell power'                 ,'Allow Hell Monastery upgrade units.'                                       );
   _mkHStrUpid(r_hell,upgr_2tier   ,'Ancient evil'               ,'New buildings, units and upgrades.'                                        );
   _mkHStrUpid(r_hell,upgr_revtele ,'Reverse teleport'           ,'Units can teleport back to Hell Teleport.'                           );
   _mkHStrUpid(r_hell,upgr_revmis  ,'Revenant missile upgrade'   ,'Increase attack and sight range, missiles become homing.'            );
   _mkHStrUpid(r_hell,upgr_totminv ,'Hell Totem and Eye invisibility',''                                                                );
   _mkHStrUpid(r_hell,upgr_bldrep  ,'Building restoration'           ,'Damaged buildings will slowly regenerate their health.'          );
   _mkHStrUpid(r_hell,upgr_mainonr ,'Free teleportation'             ,'Hell Keep can teleport on obstacles.'                            );
   _mkHStrUpid(r_hell,upgr_b478tel ,'Short distance teleportation'   ,'Hell Symbols, Towers and Totems can teleport to short distance.' );
   _mkHStrUpid(r_hell,upgr_hinvuln ,'Invulnerability'                ,'Invulnerability spheres for Hell Altar.'                         );
   _mkHStrUpid(r_hell,upgr_bldenrg ,'Built-in Hell Symbol'           ,'Additional energy for Hell Keep.'                                );
   //_mkHStrUpid(r_hell,upgr_liqwalk ,'Hell Run'                       ,'Hell units can walk on liquids.'                                 );


   _mkHStrUid(UID_UCommandCenter  ,'UAC Command Center'         ,'Builds base.'                    );
   _mkHStrUid(UID_UMilitaryUnit   ,'UAC Military unit'          ,'Trains units.'                   );
   _mkHStrUid(UID_UGenerator      ,'UAC Generator'              ,'Generates energy.'               );
   _mkHStrUid(UID_UWeaponFactory  ,'UAC Weapon Factory'         ,'Research upgrades.'              );
   _mkHStrUid(UID_UTurret         ,'UAC Chaingun Turret'        ,'Defensive structure.'            );
   _mkHStrUid(UID_URadar          ,'UAC Radar'                  ,'Reveals map.'                    );
   _mkHStrUid(UID_UVehicleFactory ,'UAC Tech Center'            ,'Upgrades units.'                 );
   _mkHStrUid(UID_UPTurret        ,'UAC Plasma turret'          ,'Advanced defensive structure.'   );
   _mkHStrUid(UID_URocketL        ,'UAC Rocket Launcher Station','Provide a missile strike. Missile strike requires "Missile strike" research.');
   _mkHStrUid(UID_URTurret        ,'UAC Rocket turret'          ,'Advanced defensive structure.'   );
   _mkHStrUid(UID_Mine            ,'Mine','');

   _mkHStrUid(UID_Engineer   ,'Engineer'         ,'');
   _mkHStrUid(UID_Medic      ,'Medic'            ,'');
   _mkHStrUid(UID_Sergant    ,'Sergeant'         ,'');
   _mkHStrUid(UID_Commando   ,'Commando'         ,'');
   _mkHStrUid(UID_Bomber     ,'Artillery soldier','');
   _mkHStrUid(UID_Major      ,'Major'            ,'');
   _mkHStrUid(UID_BFG        ,'BFG Marine'       ,'');
   _mkHStrUid(UID_FAPC       ,'Air APC'          ,'');
   _mkHStrUid(UID_UTransport ,'Air APC'          ,'');
   _mkHStrUid(UID_APC        ,'Ground APC'       ,'');
   _mkHStrUid(UID_Terminator ,'UAC Terminator'   ,'');
   _mkHStrUid(UID_Tank       ,'UAC Tank'         ,'');
   _mkHStrUid(UID_Flyer      ,'UAC Fighter'      ,'');

   _mkHStrUpid(r_uac ,upgr_attack  ,'Ranged attack upgrade'  ,'Increase damage of ranged attacks.'                                 );
   _mkHStrUpid(r_uac ,upgr_armor   ,'Infantry armor upgrade' ,'Increase infantry armor.'                                           );
   _mkHStrUpid(r_uac ,upgr_build   ,'Buildings armor upgrade','Increase buildings armor.'                                          );
   _mkHStrUpid(r_uac ,upgr_melee   ,'Advanced repair and healing'
                                                           ,'Increases the efficiency of repair/healing of Engineers and Medics.');
   _mkHStrUpid(r_uac ,upgr_mspeed  ,'Lightweight armor'      ,'Increase infantry move speed.'                                      );
   _mkHStrUpid(r_uac ,upgr_plsmt   ,'APC turret'             ,'Weapon for APCs.'                                                   );
   _mkHStrUpid(r_uac ,upgr_vision  ,'Detector device'        ,'Radar and mines becomes detectors.'                                 );
   _mkHStrUpid(r_uac ,upgr_towers  ,'Turrets range upgrade'  ,'Increased attack range of defensive structures.'                    );
   _mkHStrUpid(r_uac ,upgr_5bld    ,'Radar upgrade'          ,'Increase radar scouting time and radius.'                           );
   _mkHStrUpid(r_uac ,upgr_mainm   ,'Command Center engines' ,'Command Center gains ability to fly.'                               );
   _mkHStrUpid(r_uac ,upgr_ucomatt ,'Command Center turret'  ,'Flying Command Center will be able to attack.'                      );
   _mkHStrUpid(r_uac ,upgr_mainr   ,'Command Center range'   ,'Increased Command Center view/build range.'                         );
   _mkHStrUpid(r_uac ,upgr_mines   ,'Mines'                  ,'Engineer ability.'                                                  );
   _mkHStrUpid(r_uac ,upgr_minesen ,'Mine-sensor'            ,'Mine ability.'                                                      );
   _mkHStrUpid(r_uac ,upgr_6bld    ,'Advanced armory'        ,'Tech Center will be able to upgrade own units.'                     );
   _mkHStrUpid(r_uac ,upgr_2tier   ,'High technologies'      ,'New 2 buildings, units and upgrades.'             );
   _mkHStrUpid(r_uac ,upgr_blizz   ,'Missile strike'         ,'Missile for Rocket Launcher Station.'             );
   _mkHStrUpid(r_uac ,upgr_mechspd ,'Advanced engines'       ,'Increase mechs move speed.'                       );
   _mkHStrUpid(r_uac ,upgr_mecharm ,'Mech armor upgrade'     ,'Increase mechs armor.'                            );
   _mkHStrUpid(r_uac ,upgr_6bld2   ,'Fast rearming'          ,'Decreased Tech Center cooldown.'                  );
   _mkHStrUpid(r_uac ,upgr_mainonr ,'Free placement'         ,'Command center will be able to land on obstacles.');
   _mkHStrUpid(r_uac ,upgr_turarm  ,'Turrets armor'          ,'Additional armor for turrets.'                    );
   _mkHStrUpid(r_uac ,upgr_rturrets,'Rocket turrets'         ,'Turrets can upgrade to Rocket turrets.'           );
   _mkHStrUpid(r_uac ,upgr_bldenrg ,'Built-in generator'     ,'Additional energy for Command Center.'            );
   //_mkHStrUpid(r_uac ,upgr_liqwalk ,'Protective Suits'       ,'UAC Infantry can walk on liquids.'                );

   t:='ignore enemies';
   _mkHStrXY(3,0 ,0,0,'Move, '+t+' ('      +#18+'Q'+#25+')');
   _mkHStrXY(3,1 ,0,0,'Stop, '+t+' ('      +#18+'W'+#25+')');
   _mkHStrXY(3,2 ,0,0,'Patrol, '+t+' ('    +#18+'E'+#25+')');
   t:='attack enemies';
   _mkHStrXY(3,3 ,0,0,'Move, '+t+' ('      +#18+'A'+#25+')');
   _mkHStrXY(3,4 ,0,0,'Stop, '+t+' ('      +#18+'S'+#25+')');
   _mkHStrXY(3,5 ,0,0,'Patrol, '+t+' ('    +#18+'D'+#25+')');
   _mkHStrXY(3,6 ,0,0,'Action ('           +#18+'Z'     +#25+')');
   _mkHStrXY(3,7 ,0,0,'Select all units (' +#18+'F2'    +#25+')');
   _mkHStrXY(3,8 ,0,0,'Destroy ('          +#18+'Delete'+#25+')');
   _mkHStrXY(3,11,0,0,'Cancel production ('+#18+'C'     +#25+')');

   _mkHStrXY(3,9 ,0,0,'Fog of war ('           +#18+'Q'+#25+')');
   _mkHStrXY(3,10,0,0,'List of game messages ('+#18+'W'+#25+')');
   _mkHStrXY(3,12,0,0,'Faster game speed ('    +#18+'A'+#25+')');
   _mkHStrXY(3,13,0,0,'Left click: skip 2 seconds ('+#18+'S'+#25+')'+#11+
                      'Right click: skip 10 seconds ('+#18+'Ctrl'+#25+'+'+#18+'S'+#25+')'+#11+
                      'Skip 1 minute ('+#18+'Alt'+#25+'+'+#18+'S'+#25+')' );
   _mkHStrXY(3,14,0,0,'Pause ('                +#18+'D'+#25+')');
   _mkHStrXY(3,15,0,0,'Player POV ('           +#18+'Z'+#25+')');
   _mkHStrXY(3,17,0,0,'All players ('          +#18+'C'+#25+')');
   _mkHStrXY(3,18,0,0,'Red player [#1] ('      +#18+'R'+#25+')');
   _mkHStrXY(3,19,0,0,'Orange player [#2] ('   +#18+'T'+#25+')');
   _mkHStrXY(3,20,0,0,'Yellow player [#3] ('   +#18+'Y'+#25+')');
   _mkHStrXY(3,21,0,0,'Green player [#4] ('    +#18+'F'+#25+')');
   _mkHStrXY(3,22,0,0,'Aqua player [#5] ('     +#18+'G'+#25+')');
   _mkHStrXY(3,23,0,0,'Blue player [#6] ('     +#18+'H'+#25+')');


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

   str_camp_o[0]         := '-Destroy all human bases and armies'+#13+'-Protect the Portal';
   str_camp_o[1]         := '-Destroy Military Base';
   str_camp_o[2]         := '-Destroy all human bases and armies'+#13+'-Protect the Portal';
   str_camp_o[3]         := '-Protect the altars for 20 minutes';
   str_camp_o[4]         := '-Destroy all human bases and armies';
   str_camp_o[5]         := '-Destroy all human bases and armies';
   str_camp_o[6]         := '-Destroy all human bases and armies';
   str_camp_o[7]         := '-Destroy Cosmodrome'+#13+'-No one human`s transport should escape';

   str_camp_m[0]         := #18+'Date:'+#25+#12+'15.11.2145'+#12+#18+'Location:'+#25+#12+'PHOBOS'+#12+#18+'Area:'+#25+#12+'Anomaly Zone';
   str_camp_m[1]         := #18+'Date:'+#25+#12+'16.11.2145'+#12+#18+'Location:'+#25+#12+'PHOBOS'+#12+#18+'Area:'+#25+#12+'Hall crater';
   str_camp_m[2]         := #18+'Date:'+#25+#12+'15.11.2145'+#12+#18+'Location:'+#25+#12+'DEIMOS'+#12+#18+'Area:'+#25+#12+'Anomaly Zone';
   str_camp_m[3]         := #18+'Date:'+#25+#12+'16.11.2145'+#12+#18+'Location:'+#25+#12+'DEIMOS'+#12+#18+'Area:'+#25+#12+'Swift crater';
   str_camp_m[4]         := #18+'Date:'+#25+#12+'18.11.2145'+#12+#18+'Location:'+#25+#12+'MARS'  +#12+#18+'Area:'+#25+#12+'Hellas Area';
   str_camp_m[5]         := #18+'Date:'+#25+#12+'19.11.2145'+#12+#18+'Location:'+#25+#12+'MARS'  +#12+#18+'Area:'+#25+#12+'Hellas Area';
   str_camp_m[6]         := #18+'Date:'+#25+#12+'18.11.2145'+#12+#18+'Location:'+#25+#12+'EARTH' +#12+#18+'Area:'+#25+#12+'Unknown';
   str_camp_m[7]         := #18+'Date:'+#25+#12+'19.11.2145'+#12+#18+'Location:'+#25+#12+'EARTH' +#12+#18+'Area:'+#25+#12+'Unknown';  }

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
   str_cmp_mn[11] := 'Hell #11: Cosmodrome';
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
   str_cmp_mn[22] := 'UAC #11: Battle For Mars';

   str_cmp_ob[1 ] := '-Destroy all human bases and armies'+#13+'-Protect portal';
   str_cmp_ob[2 ] := '-Destroy Toxin Refinery';
   str_cmp_ob[3 ] := '-Destroy Military Base';
   str_cmp_ob[4 ] := '-Destroy all human bases and armies'+#13+'-Cyberdemon must survive'+#13+'-Protect portal';
   str_cmp_ob[5 ] := '-Destroy Nuclear Plant'+#13+'-Cyberdemon must survive';
   str_cmp_ob[6 ] := '-Destroy Science Center'+#13+'-Cyberdemon must survive';
   str_cmp_ob[7 ] := '-Destroy all human bases and armies';
   str_cmp_ob[8 ] := '-Kill all humans!';
   str_cmp_ob[9 ] := '-Protect Hell Fortess'+#13+'-Destroy all human towns and armies';
   str_cmp_ob[10] := '-Destroy all industrial buildings'+#13+'-Destroy all command centers';
   str_cmp_ob[11] := '-Destroy all military bases';
   str_cmp_ob[12] := '-Find, protect and reapir'+#13+'Command Center'+#13+'-At least one engineer must survive';
   str_cmp_ob[13] := '-Find and repair 5 Super Generators';
   str_cmp_ob[14] := '-Destroy all bases and armies of hell'+#13+'around portal until the arrival of'+#13+'enemy reinforcements(for 20 minutes)';
   str_cmp_ob[15] := '-Destroy all bases and armies of hell'+#13+'-Protect portal';
   str_cmp_ob[16] := '-Repair and protect Science Center'+#13+'-Destroy all bases and armies of hell';
   str_cmp_ob[17] := '-Destroy fortess of hell';
   str_cmp_ob[18] := '-Destroy all altars of hell'+#13+'-Protect portal';
   str_cmp_ob[19] := '-Reach the opposite side of the area';
   str_cmp_ob[20] := '-Find and kill the Spiderdemon';
   str_cmp_ob[21] := '-Cleanse the Quarry';
   str_cmp_ob[22] := '-Destroy all bases and armies of hell';

   str_cmp_map[1 ] := 'Date:'+#12+'15.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Anomaly Zone';
   str_cmp_map[2 ] := 'Date:'+#12+'15.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Hall crater';
   str_cmp_map[3 ] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Drunlo crater';
   str_cmp_map[4 ] := 'Date:'+#12+'15.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Anomaly Zone';
   str_cmp_map[5 ] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Swift crater';
   str_cmp_map[6 ] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Voltaire Area';
   str_cmp_map[7 ] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'MARS'  +#12+'Area:'+#12+'Hellas Area';
   str_cmp_map[8 ] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'MARS'  +#12+'Area:'+#12+'Hellas Area';
   str_cmp_map[9 ] := 'Date:'+#12+'25.11.2145'+#12+'Location:'+#12+'EARTH' +#12+'Area:'+#12+'Unknown';
   str_cmp_map[10] := 'Date:'+#12+'26.11.2145'+#12+'Location:'+#12+'EARTH' +#12+'Area:'+#12+'Unknown';
   str_cmp_map[11] := 'Date:'+#12+'27.11.2145'+#12+'Location:'+#12+'EARTH' +#12+'Area:'+#12+'Unknown';
   str_cmp_map[12] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Todd crater';
   str_cmp_map[13] := 'Date:'+#12+'16.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Roche crater';
   str_cmp_map[14] := 'Date:'+#12+'17.11.2145'+#12+'Location:'+#12+'PHOBOS'+#12+'Area:'+#12+'Anomaly Zone';
   str_cmp_map[15] := 'Date:'+#12+'17.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Anomaly Zone';
   str_cmp_map[16] := 'Date:'+#12+'18.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Voltaire Area';
   str_cmp_map[17] := 'Date:'+#12+'18.11.2145'+#12+'Location:'+#12+'DEIMOS'+#12+'Area:'+#12+'Voltaire Area';
   str_cmp_map[18] := 'Date:'+#12+'20.11.2145'+#12+'Location:'+#12+'HELL'  +#12+'Area:'+#12+'Unknown';
   str_cmp_map[19] := 'Date:'+#12+'21.11.2145'+#12+'Location:'+#12+'HELL'  +#12+'Area:'+#12+'Unknown';
   str_cmp_map[20] := 'Date:'+#12+'22.11.2145'+#12+'Location:'+#12+'HELL'  +#12+'Area:'+#12+'Unknown';
   str_cmp_map[21] := 'Date:'+#12+'21.11.2145'+#12+'Location:'+#12+'MARS'  +#12+'Area:'+#12+'Hellas Area';
   str_cmp_map[22] := 'Date:'+#12+'22.11.2145'+#12+'Location:'+#12+'MARS'  +#12+'Area:'+#12+'Hellas Area';

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
  str_map               := 'Карта';
  str_players           := 'Игроки';
  str_mrandom           := 'Случайная карта';
  str_musicvol          := 'Громкость музыки';
  str_soundvol          := 'Громкость звуков';
  str_scrollspd         := 'Скорость пр.';
  str_mousescrl         := 'Прокр. мышью:';
  str_fullscreen        := 'В окне:';
  str_plname            := 'Имя игрока';
  str_maction           := 'Правый клик';
  str_maction2[true ]   := #18+'Движение'+#25;
  str_maction2[false]   := #17+'Движение'+#25+'+'+#17+'атака'+#25;
  str_race[r_random]    := #22+'случ.'+#25;
  str_pause             := 'Пауза';
  str_win               := 'ПОБЕДА!';
  str_lose              := 'ПОРАЖЕНИЕ!';
  str_gsaved            := 'Игра сохранена';
  str_repend            := 'Конец записи!';
  str_save              := 'Сохранить';
  str_load              := 'Загрузить';
  str_delete            := 'Удалить';
  str_svld_errors[1]    := 'Файл не'+#13+'существует!';
  str_svld_errors[2]    := 'Невозможно'+#13+'открыть файл!';
  str_svld_errors[3]    := 'Неправильный'+#13+'размер файла!';
  str_svld_errors[4]    := 'Неправильная'+#13+'версия файла!';
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
  str_gaddon            := 'Игра:';
  str_randoms           := 'Случайная схватка';
  str_apply             := 'применить';
  str_plout             := ' покинул игру';
  str_aislots           := 'Заполнить пустые слоты:';
  str_chattars          := 'Отправлять сообщения';
  str_resol             := 'Разрешение';
  str_language          := 'Язык интерфейса';
  str_req               := 'Требования: ';
  str_orders            := 'Отряды: ';
  str_all               := 'Все';

  str_starta            := 'Начальная база:';
  str_startat[0]        := '1 '+#19+'строитель'+#25;
  str_startat[1]        := '1 '+#19+'строитель'+#25+'+ 1 '+#18+'ген.'+#25;
  str_startat[2]        := '1 '+#19+'строитель'+#25+'+ 2 '+#18+'ген.'+#25;
  str_startat[3]        := '1 '+#19+'стр.'+#25+'+ 2 '+#18+'ген.'+#25+'+ 2 '+#17+'б.'+#25;
  str_startat[4]        := '2 '+#19+'строителя'+#25;
  str_startat[5]        := '1 '+#19+'стр.'+#25+'+ 100 энергии';

  str_sstarts           := 'Показывать старты:';

  str_gmodet            := 'Режим игры:';
  str_gmode[gm_scir ]   := #18+'Схватка'+#25;
  str_gmode[gm_2fort]   := #16+'Две крепости'+#25;
  str_gmode[gm_3fort]   := #17+'Три крепости'+#25;
  str_gmode[gm_ct   ]   := #19+'Захват точек'+#25;
  str_gmode[gm_inv  ]   := #20+'Вторжение'+#25;
  str_gmode[gm_coop ]   := #15+'Штурм'+#25;

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

  str_hint_m[0]         := 'Меню ('          +#18+'Esc'+#25+')';
  str_hint_m[2]         := 'Пауза ('         +#18+'Pause/Break'+#25+')';

  str_hint_a[0]         := 'Энергия (свободная/максимальная)';
  str_hint_a[1]         := 'Армия (юниты и здания)';

  _mkHStrUid(UID_HKeep        ,'Адская Крепость' ,'Строит базу.'                          );
  _mkHStrUid(UID_HGate        ,'Адские Врата'    ,'Призывает юнитов.'                     );
  _mkHStrUid(UID_HSymbol      ,'Адский Символ'   ,'Производит энергию.'                   );
  _mkHStrUid(UID_HPools       ,'Адские Омуты'    ,'Исследует улучшения.'                  );
  _mkHStrUid(UID_HTower       ,'Адская Башня'    ,'Защитное сооружение.'                  );
  _mkHStrUid(UID_HTeleport    ,'Адский Телепорт' ,'Перемещает юнитов в любую точку карты.');
  _mkHStrUid(UID_HMonastery   ,'Адский Монастырь','Улучшает юнитов.'                      );
  _mkHStrUid(UID_HTotem       ,'Адский Тотем'    ,'Продвинутое защитное сооружение.'      );
  _mkHStrUid(UID_HAltar       ,'Адский Алтарь'   ,'Временно делает юнитов неуязвимыми.'   );
  _mkHStrUid(UID_HFortress    ,'Адский Замок'    ,'Временно делает юнитов неуязвимыми.'   );
  _mkHStrUid(UID_HMilitaryUnit,'Проклятая Войсковая часть','Позволяет производить зомби.' );

  _mkHStrUpid(r_hell,upgr_attack  ,'Улучшение дальней атаки'        ,''                                         );
  _mkHStrUpid(r_hell,upgr_armor   ,'Улучшение защиты юнитов'        ,''                                         );
  _mkHStrUpid(r_hell,upgr_build   ,'Улучшение защиты зданий'        ,''                                         );
  _mkHStrUpid(r_hell,upgr_melee   ,'Улучшение ближней атаки'        ,''                                         );
  _mkHStrUpid(r_hell,upgr_regen   ,'Регенерация'                    ,'Раненые юниты медленно восстанавливают свое здоровье.'                   );
  _mkHStrUpid(r_hell,upgr_pains   ,'Болевой порог'                  ,'Уменьшает шанс "pain state".'                                            );
  _mkHStrUpid(r_hell,upgr_vision  ,'Адский глаз'                    ,'Способность Lost Soul и радиус зрения Адского Глаза.'                    );
  _mkHStrUpid(r_hell,upgr_towers  ,'Радиус атаки башен'             ,'Увеличение радиуса атаки и зрения защитных сооружений.'                  );
  _mkHStrUpid(r_hell,upgr_5bld    ,'Улучшение телепорта'            ,'Уменьшает время перезарядки Телепорта.'                                  );
  _mkHStrUpid(r_hell,upgr_mainm   ,'Телепортация адской крепости'   ,'Адская Крепость может перемещаться в любую свободную точку карты.'       );
  _mkHStrUpid(r_hell,upgr_paina   ,'Аура разрушения'                ,'Адская крепость наносит урон всем врагам вокруг.'                        );
  _mkHStrUpid(r_hell,upgr_mainr   ,'Радиус зрения адской крепости'  ,'Увеличивает радиус зрения и дистанции строительства для Aдской Крепости.');
  _mkHStrUpid(r_hell,upgr_pinkspd ,'Злость демона'                  ,'Увеличение скорости юнита Demon.'                                        );
  _mkHStrUpid(r_hell,upgr_6bld    ,'Адска сила'                     ,'Позволяет Адскому Монастырю улучшать своих юнитов.'                      );
  _mkHStrUpid(r_hell,upgr_misfst  ,'Огневая мощь'                   ,'Увеличивает скорсоть полета снарядов юнитов Imp, Cacodemon и Baron of Hell/Hell Knight.'                              );
  _mkHStrUpid(r_hell,upgr_2tier   ,'Древнее зло'                    ,'Второй уровень зданий, юнитов и улучшений.'                              );
  _mkHStrUpid(r_hell,upgr_revtele ,'Обратный телепорт'              ,'Юниты могут перемещаться обратно в Адский Телепорт.'                     );
  _mkHStrUpid(r_hell,upgr_revmis  ,'Улучшение атаки юнита Revenant' ,'Снаряды становятся самонаводящимися.'                                    );
  _mkHStrUpid(r_hell,upgr_totminv ,'Невидимость для Тотема и Глаза' ,'Адский Тотем и Глаз становятся невидимыми.'                              );
  _mkHStrUpid(r_hell,upgr_bldrep  ,'Восстановление зданий'          ,'Поврежденные здания медленно восстанавливают себя.'                      );
  _mkHStrUpid(r_hell,upgr_mainonr ,'Свободная телепортация'         ,'Адская Крепость может перемещаться на скалы, озера и др. препятствия.'   );
  _mkHStrUpid(r_hell,upgr_b478tel ,'Телепортация на короткие дистанции'
                                                                  ,'Адские Символы, Башни и Тотемы могут телепортироваться на короткое расстояние.');
  _mkHStrUpid(r_hell,upgr_hinvuln ,'Неуязвимость'                   ,'Сферы неуязвимости для Адского Алтаря.'                                  );
  _mkHStrUpid(r_hell,upgr_bldenrg ,'Встроеный адский символ'        ,'Дополнительная энергия для Адской Крепости.'                             );
  //_mkHStrUpid(r_hell,upgr_liqwalk ,'Адский бег'                     ,'Юниты Ада могут ходить по жидкостям.'                                    );

  _mkHStrUid(UID_UCommandCenter  ,'Командный Центр'        ,'Строит базу.'                    );
  _mkHStrUid(UID_UMilitaryUnit   ,'Войсковая Часть'        ,'Тренирует юнитов.'               );
  _mkHStrUid(UID_UGenerator      ,'Генератор'              ,'Производит энергию.'             );
  _mkHStrUid(UID_UWeaponFactory  ,'Завод Вооружений'       ,'Исследует улучшения.'            );
  _mkHStrUid(UID_UTurret         ,'Пулеметная Турель'      ,'Защитное сооружение.'            );
  _mkHStrUid(UID_URadar          ,'Радар'                  ,'Раскрывает карту.'               );
  _mkHStrUid(UID_UVehicleFactory ,'Технический Центр'      ,'Улучшает юнитов.'                );
  _mkHStrUid(UID_UPTurret        ,'Плазменная Турель'      ,'Продвинутое защитное сооружение.');
  _mkHStrUid(UID_URocketL        ,'Станция Ракетного Залпа','Производит ракетный удар. Для залпа требуется исследование "Ракетный удар".');
  _mkHStrUid(UID_URTurret        ,'Ракетная Турель'        ,'Продвинутое защитное сооружение.');
  _mkHStrUid(UID_Mine            ,'Мина','');

  _mkHStrUid(UID_Engineer   ,'Инженер'            ,'');
  _mkHStrUid(UID_Medic      ,'Медик'              ,'');
  _mkHStrUid(UID_Sergant    ,'Сержант'            ,'');
  _mkHStrUid(UID_Commando   ,'Коммандо'           ,'');
  _mkHStrUid(UID_Bomber     ,'Гранатометчик'      ,'');
  _mkHStrUid(UID_Major      ,'Майор'              ,'');
  _mkHStrUid(UID_BFG        ,'Солдат с BFG'       ,'');
  _mkHStrUid(UID_FAPC       ,'Воздушный транспорт','');
  _mkHStrUid(UID_UTransport ,'Воздушный транспорт','');
  _mkHStrUid(UID_APC        ,'БТР'                ,'');
  _mkHStrUid(UID_Terminator ,'Терминатор'         ,'');
  _mkHStrUid(UID_Tank       ,'Танк'               ,'');
  _mkHStrUid(UID_Flyer      ,'Истребитель'        ,'');

  _mkHStrUpid(r_uac ,upgr_attack  ,'Улучшение дальней атаки'  ,''                                );
  _mkHStrUpid(r_uac ,upgr_armor   ,'Улучшение защиты пехоты'  ,''                                );
  _mkHStrUpid(r_uac ,upgr_build   ,'Улучшение защиты зданий'  ,''                                );
  _mkHStrUpid(r_uac ,upgr_melee   ,'Ремонт и лечение'         ,'Увеличение эффективности ремонта Инженером и лечения Медиком.');
  _mkHStrUpid(r_uac ,upgr_mspeed  ,'Легковесная броня'        ,'Увеличение скорости передвижения пехоты.'                 );
  _mkHStrUpid(r_uac ,upgr_plsmt   ,'Турель на транспорте'     ,'Оружие для транспортников.'                               );
  _mkHStrUpid(r_uac ,upgr_vision  ,'Детекторы'                ,'Радар и Мины становятся детекторами.'                     );
  _mkHStrUpid(r_uac ,upgr_towers  ,'Радиус атаки турелей'     ,'Увеличение радиуса атаки и зрения защитных сооружений.'   );
  _mkHStrUpid(r_uac ,upgr_5bld    ,'Улучшение радара'         ,'Увеличивает радиус и время разведки Радара.'              );
  _mkHStrUpid(r_uac ,upgr_mainm   ,'Двигатели Командного центра','Командный Центр может летать.'                          );
  _mkHStrUpid(r_uac ,upgr_ucomatt ,'Турель Командного центра' ,'Летающий Командный Центр может атаковать.'                );
  _mkHStrUpid(r_uac ,upgr_mainr   ,'Радиус зрения Командного центра','Увеличивает радиус зрения и дистанции строительства Командного Центра.');
  _mkHStrUpid(r_uac ,upgr_mines   ,'Мины'                     ,'Способность Инженера.'                                    );
  _mkHStrUpid(r_uac ,upgr_minesen ,'Мина-сенсор'              ,'Способность Мин.'                                         );
  _mkHStrUpid(r_uac ,upgr_6bld    ,'Дополнительное вооружение','Технический Центр может улучшать юнитов.'                 );
  _mkHStrUpid(r_uac ,upgr_2tier   ,'Выские технологии'        ,'Второй уровень зданий, юнитов и улучшений.'               );
  _mkHStrUpid(r_uac ,upgr_blizz   ,'Ракетный удар'            ,'Снаряд для станции Ракетного Залпа.'                      );
  _mkHStrUpid(r_uac ,upgr_mechspd ,'Продвинутые двигатели'    ,'Увеличивает скорость передвижения техники.'               );
  _mkHStrUpid(r_uac ,upgr_mecharm ,'Улучшение защиты техники' ,''                             );
  _mkHStrUpid(r_uac ,upgr_6bld2   ,'Быстрое перевооружение'   ,'Уменьшение времени парезарядки Технического Центра при улучшении юнитов.');
  _mkHStrUpid(r_uac ,upgr_mainonr ,'Свободное приземление'    ,'Командный Центр может приземляться на камни, озера и др. препятствия.');
  _mkHStrUpid(r_uac ,upgr_turarm  ,'Защита для турелей'       ,'Дополнительное увеличение защиты Турелей.'                );
  _mkHStrUpid(r_uac ,upgr_rturrets,'Ракетные турели'          ,'Обычные турели могут быть улучшены до ракетных.'          );
  _mkHStrUpid(r_uac ,upgr_bldenrg ,'Встроенный генератор'     ,'Дополнительна энергия для Командного Центра.'             );
  //_mkHStrUpid(r_uac ,upgr_liqwalk ,'Защитные костюмы'         ,'Пехота может ходить по жидкостям.'                        );

  t:='игнорировать врагов';
  _mkHStrXY(3,0 ,0,0,'Двигаться, '    +t+' ('+#18+'Q'+#25+')');
  _mkHStrXY(3,1 ,0,0,'Стоять, '       +t+' ('+#18+'W'+#25+')');
  _mkHStrXY(3,2 ,0,0,'Патрулировать, '+t+' ('+#18+'E'+#25+')');
  t:='атаковать врагов';
  _mkHStrXY(3,3 ,0,0,'Двигаться, '    +t+' ('+#18+'A'+#25+')');
  _mkHStrXY(3,4 ,0,0,'Стоять, '       +t+' ('+#18+'S'+#25+')');
  _mkHStrXY(3,5 ,0,0,'Патрулировать, '+t+' ('+#18+'D'+#25+')');
  _mkHStrXY(3,6 ,0,0,'Действие ('            +#18+'Z'     +#25+')');
  _mkHStrXY(3,7 ,0,0,'Выбрать всех юнитов (' +#18+'F2'    +#25+')');
  _mkHStrXY(3,8 ,0,0,'Уничтожить ('          +#18+'Delete'+#25+')');
  _mkHStrXY(3,11,0,0,'Отмена производства (' +#18+'C'+#25+')');

  _mkHStrXY(3,9 ,0,0,'Туман войны ('             +#18+'Q'+#25+')');
  _mkHStrXY(3,10,0,0,'Список игровых сообщений ('+#18+'W'+#25+')');
  _mkHStrXY(3,12,0,0,'Включить/выключить ускоренный просмотр ('+#18+'A'+#25+')');
  _mkHStrXY(3,13,0,0,'Левый клик: пропустить 2 секунды (' +#18+'S'+#25+')'+#11+
                     'Правый клик: пропустить 10 секунд ('+#18+'Ctrl'+#25+'+'+#18+'S'+#25+')'+#11+
                     'Пропустить 1 минуту ('              +#18+'Alt'+#25+'+'+#18+'S'+#25+')' );
  _mkHStrXY(3,14,0,0,'Пауза ('                   +#18+'D'+#25+')');
  _mkHStrXY(3,15,0,0,'Камера игрока ('           +#18+'Z'+#25+')');
  _mkHStrXY(3,17,0,0,'Все игроки ('              +#18+'C'+#25+')');
  _mkHStrXY(3,18,0,0,'Красный игрок [#1] ('      +#18+'R'+#25+')');
  _mkHStrXY(3,19,0,0,'Оранжевый игрок [#2] ('    +#18+'T'+#25+')');
  _mkHStrXY(3,20,0,0,'Желтый игрок [#3] ('       +#18+'Y'+#25+')');
  _mkHStrXY(3,21,0,0,'Зеленый игрок [#4] ('      +#18+'F'+#25+')');
  _mkHStrXY(3,22,0,0,'Бирюзовый игрок [#5] ('    +#18+'G'+#25+')');
  _mkHStrXY(3,23,0,0,'Синий игрок [#6] ('        +#18+'H'+#25+')');


  {str_camp_t[0]         := 'Hell #1: Вторжение на Фобос';
  str_camp_t[1]         := 'Hell #2: Военная база';
  str_camp_t[2]         := 'Hell #3: Вторжение на Деймос';
  str_camp_t[3]         := 'Hell #4: Пентаграмма смерти';
  str_camp_t[4]         := 'Hell #7: Каньон';
  str_camp_t[5]         := 'Hell #8: Ад на Марсе';
  str_camp_t[6]         := 'Hell #5: Ад на Земле';
  str_camp_t[7]         := 'Hell #6: Космодром';

  str_camp_o[0]         := '-Уничтожь все людские базы и армии'+#13+'-Защити портал';
  str_camp_o[1]         := '-Уничтожь военную базу';
  str_camp_o[2]         := '-Уничтожь все людские базы и армии'+#13+'-Защити портал';
  str_camp_o[3]         := '-Защити алтари в течении 20 минут';
  str_camp_o[4]         := '-Уничтожь все людские базы и армии';
  str_camp_o[5]         := '-Уничтожь все людские базы и армии';
  str_camp_o[6]         := '-Уничтожь все людские базы и армии';
  str_camp_o[7]         := '-Уничтожь космодром'+#13+'-Ни один людской транспорт не должен'+#13+'уйти';

  str_camp_m[0]         := #18+'Дата:'+#25+#12+'15.11.2145'+#12+#18+'Место:'+#25+#12+'ФОБОС' +#12+#18+'Район:'+#25+#12+'Аномалия';
  str_camp_m[1]         := #18+'Дата:'+#25+#12+'16.11.2145'+#12+#18+'Место:'+#25+#12+'ФОБОС' +#12+#18+'Район:'+#25+#12+'Кратер Халл';
  str_camp_m[2]         := #18+'Дата:'+#25+#12+'15.11.2145'+#12+#18+'Место:'+#25+#12+'ДЕЙМОС'+#12+#18+'Район:'+#25+#12+'Аномалия';
  str_camp_m[3]         := #18+'Дата:'+#25+#12+'16.11.2145'+#12+#18+'Место:'+#25+#12+'ДЕЙМОС'+#12+#18+'Район:'+#25+#12+'Кратер Свифт';
  str_camp_m[4]         := #18+'Дата:'+#25+#12+'18.11.2145'+#12+#18+'Место:'+#25+#12+'МАРС'  +#12+#18+'Район:'+#25+#12+'Равнина Хеллас';
  str_camp_m[5]         := #18+'Дата:'+#25+#12+'19.11.2145'+#12+#18+'Место:'+#25+#12+'МАРС'  +#12+#18+'Район:'+#25+#12+'Равнина Хеллас';
  str_camp_m[6]         := #18+'Дата:'+#25+#12+'18.11.2145'+#12+#18+'Место:'+#25+#12+'ЗЕМЛЯ' +#12+#18+'Район:'+#25+#12+'Неизвестно';
  str_camp_m[7]         := #18+'Дата:'+#25+#12+'19.11.2145'+#12+#18+'Место:'+#25+#12+'ЗЕМЛЯ' +#12+#18+'Район:'+#25+#12+'Неизвестно';  }

  _makeHints;
end;


procedure swLNG;
begin
  if(_lng)
  then lng_rus
  else lng_eng;
end;



