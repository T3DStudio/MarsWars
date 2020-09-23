procedure _mkHStrXY(tab,i,x,y:byte;STR:string);
begin
   if(i=255)then i:=(y div 3)+x;
   if(i>_uts)then exit;
   str_hint[tab,r_hell,i ] := STR;
   str_hint[tab,r_uac ,i ] := str_hint[tab,r_hell,i ];
end;

procedure _mkHStrUid(uid:byte;NAME,DESCR:string);
begin
   str_un_name [uid]:=name;
   str_un_descr[uid]:=descr;
end;

procedure _mkHStr(tb,rc,ucl:byte;NAME,DESCR:string);
var uid:byte;
begin
   case tb of
   0:begin
        uid:=cl2uid[rc,true ,ucl];
        str_un_name [uid]:=name;
        str_un_descr[uid]:=descr;
     end;
   1:begin
        uid:=cl2uid[rc,false,ucl];
        str_un_name [uid]:=name;
        str_un_descr[uid]:=descr;
     end;
   2:begin
        str_up_name [ucl+(_uts*rc)]:=name;
        str_up_descr[ucl+(_uts*rc)]:=descr;
     end;
   end;
end;

function _gHK(tab,ucl:byte):shortstring;
const hot_keys : array[0..14] of char = ('R','T','Y','F','G','H','V','B','N','U','I','O','J','K','L');
begin
   case tab of
   0  : _gHK:=#18+hot_keys[ucl]+#25;
   1  : if(ucl<9)
        then _gHK:=#18+hot_keys[ucl]+#25
        else _gHK:=#18+'Ctrl'+#25+'+'+#18+hot_keys[ucl-9]+#25 ;
   2  : if(ucl<15)
        then _gHK:=#18+hot_keys[ucl]+#25
        else _gHK:=#18+'Ctrl'+#25+'+'+#18+hot_keys[ucl-15]+#25 ;
   else _gHK:='';
   end;
end;

procedure _makeHints;
var rc,ucl,uid:byte;
    enrg,NAME,DESCR,TIME,REQ:shortstring;
begin
   for rc:=1 to 2 do
   for ucl:=0 to _uts do
   begin
      if(ucl<9)then
      begin
         REQ:='';
         uid  :=cl2uid[rc,true,ucl];
         if(uid>0)then
         begin
         NAME :=str_un_name [uid];
         DESCR:=str_un_descr[uid];
         with _ulst[uid] do
         begin
            enrg:=b2s(renerg);
            TIME:=i2s(mhits div bld_s div 2);
            if(ruid <255)then REQ:=str_un_name[ruid];
            if(rupgr<255)then
            begin
               if(REQ<>'')then REQ:=REQ+', ';
               REQ:=REQ+str_up_name[rupgr+(_uts*rc)];
            end;
         end;
         str_hint[0,rc,ucl]:= NAME+' ('+_gHK(0,ucl)+') ['+#16+TIME+#25+'] '+'{'+#19+enrg+#25+'}';
         str_hint[0,rc,ucl]:=str_hint[0,rc,ucl]+#11+DESCR+#11;
         if(REQ<>'')then str_hint[0,rc,ucl]:=str_hint[0,rc,ucl]+#17+str_req+#25+REQ;
         end;
      end;

      if(ucl<19)then
      begin
         REQ:='';
         uid  :=cl2uid[rc,false,ucl];
         if(uid>0)then
         begin
         NAME :=str_un_name [uid];
         DESCR:=str_un_descr[uid];
         with _ulst[uid] do
         begin
            enrg:=b2s(renerg);
            TIME:=b2s(trt div vid_fps);
            if(ruid <255)then REQ:=str_un_name[ruid];
            if(rupgr<255)then
            begin
               if(REQ<>'')then REQ:=REQ+', ';
               REQ:=REQ+str_up_name[rupgr+(_uts*rc)];
            end;
         end;
         str_hint[1,rc,ucl]:= NAME+' ('+_gHK(1,ucl)+') ['+#16+TIME+#25+'] '+'{'+#19+enrg+#25+'}';
         str_hint[1,rc,ucl]:=str_hint[1,rc,ucl]+#11+DESCR+#11;
         if(REQ<>'')then str_hint[1,rc,ucl]:=str_hint[1,rc,ucl]+#17+str_req+#25+REQ;
         end;
      end;

      if(ucl<=MaxUpgrs)then
      begin
         REQ:='';
         uid:=ucl+(_uts*rc);
         enrg :=b2s(_pne_r[rc,ucl]);
         TIME :=i2s(upgrade_time[rc ,ucl  ] div vid_fps);
         NAME :=str_up_name [uid];
         DESCR:=str_up_descr[uid];

         if(upgrade_ruid [rc,ucl]<255)then REQ:=str_un_name[upgrade_ruid[rc,ucl]];
         if(upgrade_rupgr[rc,ucl]<255)then
         begin
            if(REQ<>'')then REQ:=REQ+', ';
            REQ:=REQ+str_up_name[upgrade_rupgr[rc,ucl]+(_uts*rc)];
         end;

         str_hint[2,rc,ucl]:= NAME+' ('+_gHK(2,ucl)+') ['+#16+TIME+#25+'] '+'{'+#19+enrg+#25+'}'+' x'+#17+b2s(upgrade_cnt[rc ,ucl ])+#25;
         if(ucl in upgr_1[rc])then str_hint[2,rc,ucl]:= str_hint[2,rc,ucl]+#15+' *'+#25;

         str_hint[2,rc,ucl]:=str_hint[2,rc,ucl]+#11+DESCR+#11;
         if(REQ<>'')then str_hint[2,rc,ucl]:=str_hint[2,rc,ucl]+#17+str_req+#25+REQ;
      end;
   end;
end;

procedure lng_eng;
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

   str_hint_m[0]         := 'Menu (' +#18+'Esc'+#25+')';
   str_hint_m[2]         := 'Pause ('+#18+'Pause/Break'+#25+')';


   _mkHStr(0,r_hell,0 ,'Hell Keep'      ,'Builds base.'                 );
   _mkHStr(0,r_hell,1 ,'Hell Gate'      ,'Summons units.'               );
   _mkHStr(0,r_hell,2 ,'Hell Symbol'    ,'Generates energy.'            );
   _mkHStr(0,r_hell,3 ,'Hell Pools'     ,'Research upgrades.'           );
   _mkHStr(0,r_hell,4 ,'Hell Tower'     ,'Defensive structure.'         );
   _mkHStr(0,r_hell,5 ,'Hell Teleport'  ,'Teleports units to any place.');
   _mkHStr(0,r_hell,6 ,'Hell Monastery' ,'Upgrades units.'                    );
   _mkHStr(0,r_hell,7 ,'Hell Totem'     ,'Advanced defensive structure.'      );
   _mkHStr(0,r_hell,8 ,'Hell Altar'     ,'Casts "Invulnerability" on units.'  );

   _mkHStrUid(UID_HMilitaryUnit ,'Hell Military Unit','Corrupted UAC Military Unit.');

   _mkHStr(1,r_hell,0 ,'Lost Soul'      ,'');
   _mkHStr(1,r_hell,1 ,'Imp'            ,'');
   _mkHStr(1,r_hell,2 ,'Demon'          ,'');
   _mkHStr(1,r_hell,3 ,'Cacodemon'      ,'');
   _mkHStr(1,r_hell,4 ,'Baron of Hell / Hell Knight','');
   _mkHStr(1,r_hell,5 ,'Cyberdemon'     ,'');
   _mkHStr(1,r_hell,6 ,'Mastermind'     ,'');
   _mkHStr(1,r_hell,7 ,'Pain Elemental' ,'');
   _mkHStr(1,r_hell,8 ,'Revenant'       ,'');
   _mkHStr(1,r_hell,9 ,'Mancubus'       ,'');
   _mkHStr(1,r_hell,10,'Arachnotron'    ,'');
   _mkHStr(1,r_hell,11,'ArchVile'       ,'');
   _mkHStr(1,r_hell,12,'Zombie Medic'   ,'');
   _mkHStr(1,r_hell,13,'Zombie Engineer','');
   _mkHStr(1,r_hell,14,'Zombie Sergeant','');
   _mkHStr(1,r_hell,15,'Zombie Commando','');
   _mkHStr(1,r_hell,16,'Zombie Bomber'  ,'');
   _mkHStr(1,r_hell,17,'Zombie Major'   ,'');
   _mkHStr(1,r_hell,18,'Zombie BFG'     ,'');

   _mkHStr(2,r_hell,upgr_attack  ,'Range attack upgrade'       ,'Increase ranged attacks damage.'                                           );
   _mkHStr(2,r_hell,upgr_armor   ,'Unit armor upgrade'         ,'Increase units armor.'                                                     );
   _mkHStr(2,r_hell,upgr_build   ,'Buildinds armor upgrade'    ,'Increase buildings armor.'                                                 );
   _mkHStr(2,r_hell,upgr_melee   ,'Melee attack upgrade'       ,'Increase melee attacks damage.'                                            );
   _mkHStr(2,r_hell,upgr_regen   ,'Regeneration'               ,'Damaged units will slowly regenerate their health.'                        );
   _mkHStr(2,r_hell,upgr_pains   ,'Pain threshold'             ,'Decrease "pain state" chance.'                                             );
   _mkHStr(2,r_hell,upgr_vision  ,'Hell eye'                   ,'Lost Soul ability & Hell Eye sight radius.'                                );
   _mkHStr(2,r_hell,upgr_towers  ,'Tower range upgrade'        ,'Increased range of defensive structures.'                                  );
   _mkHStr(2,r_hell,upgr_5bld    ,'Teleport upgrade'           ,'Decrease teleport cooldown.'                                               );
   _mkHStr(2,r_hell,upgr_mainm   ,'Hell Keep teleportaion'     ,'Hell keep can teleport to any place.'                                      );
   _mkHStr(2,r_hell,upgr_paina   ,'Decay aura'                 ,'Hell Keep will damage all enemies around.'                                 );
   _mkHStr(2,r_hell,upgr_mainr   ,'Hell Keep range upgrade'    ,'Increased Hell Keep view/build range.'                                     );
   _mkHStr(2,r_hell,upgr_pinkspd ,'Demon`s anger'              ,'Increased Demon`s speed.'                                                  );
   _mkHStr(2,r_hell,upgr_misfst  ,'Firepower'                  ,'Increase missiles speed for Imp, Cacodemon and Baron of Hell/Hell Knight.' );
   _mkHStr(2,r_hell,upgr_6bld    ,'Hell power'                 ,'Allow Hell Monastery upgrade units.'                                       );
   _mkHStr(2,r_hell,upgr_2tier   ,'Ancient evil'               ,'New buildings, units and upgrades.'                                        );
   _mkHStr(2,r_hell,upgr_revtele ,'Reverse teleport'           ,'Units can teleport back to Hell Teleport.'                           );
   _mkHStr(2,r_hell,upgr_revmis  ,'Revenant missile upgrade'   ,'Increase attack and sight range, missiles become homing.'            );
   _mkHStr(2,r_hell,upgr_totminv ,'Hell Totem and Eye invisibility',''                                                                );
   _mkHStr(2,r_hell,upgr_bldrep  ,'Building restoration'           ,'Damaged buildings will slowly regenerate their health.'          );
   _mkHStr(2,r_hell,upgr_mainonr ,'Free teleportation'             ,'Hell Keep can teleport on obstacles.'                            );
   _mkHStr(2,r_hell,upgr_b478tel ,'Short distance teleportation'   ,'Hell Symbols, Towers and Totems can teleport to short distance.' );
   _mkHStr(2,r_hell,upgr_hinvuln ,'Invulnerability'                ,'Invulnerability spheres for Hell Altar.'                         );
   _mkHStr(2,r_hell,upgr_bldenrg ,'Built-in Hell Symbol'           ,'Additional energy for Hell Keep.'                                );

   _mkHStr(0,r_uac,0 ,'UAC Command Center'         ,'Builds base.'                    );
   _mkHStr(0,r_uac,1 ,'UAC Military unit'          ,'Trains units.'                   );
   _mkHStr(0,r_uac,2 ,'UAC Generator'              ,'Generates energy.'               );
   _mkHStr(0,r_uac,3 ,'UAC Weapon Factory'         ,'Research upgrades.'              );
   _mkHStr(0,r_uac,4 ,'UAC Chaingun Turret'        ,'Defensive structure.'            );
   _mkHStr(0,r_uac,5 ,'UAC Radar'                  ,'Reveals map.'                    );
   _mkHStr(0,r_uac,6 ,'UAC Tech Center'            ,'Upgrades units.'                 );
   _mkHStr(0,r_uac,7 ,'UAC Plasma turret'          ,'Advanced defensive structure.'   );
   _mkHStr(0,r_uac,8 ,'UAC Rocket Launcher Station','Provide a missile strike. Missile strike requires "Missile strike" research.');

   _mkHStr(1,r_uac,0 ,'Engineer'         ,'');
   _mkHStr(1,r_uac,1 ,'Medic'            ,'');
   _mkHStr(1,r_uac,2 ,'Sergeant'         ,'');
   _mkHStr(1,r_uac,3 ,'Commando'         ,'');
   _mkHStr(1,r_uac,4 ,'Artillery soldier','');
   _mkHStr(1,r_uac,5 ,'Major'            ,'');
   _mkHStr(1,r_uac,6 ,'BFG Marine'       ,'');
   _mkHStr(1,r_uac,7 ,'Air APC'          ,'');
   _mkHStr(1,r_uac,8 ,'Ground APC'       ,'');
   _mkHStr(1,r_uac,9 ,'UAC Terminator'   ,'');
   _mkHStr(1,r_uac,10,'UAC Tank'         ,'');
   _mkHStr(1,r_uac,11,'UAC Fighter'      ,'');

   _mkHStr(2,r_uac ,upgr_attack  ,'Ranged attack upgrade'  ,'Increase damage of ranged attacks.'                                 );
   _mkHStr(2,r_uac ,upgr_armor   ,'Infantry armor upgrade' ,'Increase infantry armor.'                                           );
   _mkHStr(2,r_uac ,upgr_build   ,'Buildings armor upgrade','Increase buildings armor.'                                          );
   _mkHStr(2,r_uac ,upgr_melee   ,'Advanced repair and healing'
                                                           ,'Increases the efficiency of repair/healing of Engineers and Medics.');
   _mkHStr(2,r_uac ,upgr_mspeed  ,'Lightweight armor'      ,'Increase infantry move speed.'                                      );
   _mkHStr(2,r_uac ,upgr_plsmt   ,'APC turret'             ,'Weapon for APCs.'                                                   );
   _mkHStr(2,r_uac ,upgr_vision  ,'Detector device'        ,'Radar and mines becomes detectors.'                                 );
   _mkHStr(2,r_uac ,upgr_towers  ,'Turrets range upgrade'  ,'Increased attack range of defensive structures.'                    );
   _mkHStr(2,r_uac ,upgr_5bld    ,'Radar upgrade'          ,'Increase radar scouting time and radius.'                           );
   _mkHStr(2,r_uac ,upgr_mainm   ,'Command Center engines' ,'Command Center gains ability to fly.'                               );
   _mkHStr(2,r_uac ,upgr_ucomatt ,'Command Center turret'  ,'Flying Command Center will be able to attack.'                      );
   _mkHStr(2,r_uac ,upgr_mainr   ,'Command Center range'   ,'Increased Command Center view/build range.'                         );
   _mkHStr(2,r_uac ,upgr_mines   ,'Mines'                  ,'Engineer ability.'                                                  );
   _mkHStr(2,r_uac ,upgr_minesen ,'Mine-sensor'            ,'Mine ability.'                                                      );
   _mkHStr(2,r_uac ,upgr_6bld    ,'Advanced armory'        ,'Tech Center will be able to upgrade own units.'                     );
   _mkHStr(2,r_uac ,upgr_2tier   ,'High technologies'      ,'New 2 buildings, units and upgrades.'             );
   _mkHStr(2,r_uac ,upgr_blizz   ,'Missile strike'         ,'Missile for Rocket Launcher Station.'             );
   _mkHStr(2,r_uac ,upgr_mechspd ,'Advanced engines'       ,'Increase mechs move speed.'                       );
   _mkHStr(2,r_uac ,upgr_mecharm ,'Mech armor upgrade'     ,'Increase mechs armor.'                            );
   _mkHStr(2,r_uac ,upgr_6bld2   ,'Fast rearming'          ,'Decreased Tech Center cooldown.'                  );
   _mkHStr(2,r_uac ,upgr_mainonr ,'Free placement'         ,'Command center will be able to land on obstacles.');
   _mkHStr(2,r_uac ,upgr_turarm  ,'Turrets armor'          ,'Additional armor for turrets.'                    );
   _mkHStr(2,r_uac ,upgr_rturrets,'Rocket turrets'         ,'Turrets can upgrade to Rocket turrets.'           );
   _mkHStr(2,r_uac ,upgr_bldenrg ,'Built-in generator'     ,'Additional energy for Command Center.'            );

   _mkHStrXY(3,9 ,0,0,'Faster game speed ('    +#18+'Q'+#25+')');
   _mkHStrXY(3,10,0,0,'Left click: skip 2 seconds ('+#18+'W'+#25+')'+#11+'Right click: skip 10 seconds ('+#18+'Ctrl'+#25+'+'+#18+'W'+#25+')');
   _mkHStrXY(3,11,0,0,'Pause ('                +#18+'E'+#25+')');
   _mkHStrXY(3,12,0,0,'Fog of war ('           +#18+'A'+#25+')');
   _mkHStrXY(3,13,0,0,'List of game messages ('+#18+'S'+#25+')');
   _mkHStrXY(3,14,0,0,'All players ('          +#18+'Z'+#25+')');
   _mkHStrXY(3,15,0,0,'Red player [#1] ('      +#18+'X'+#25+')');
   _mkHStrXY(3,16,0,0,'Orange player [#2] ('   +#18+'C'+#25+')');
   _mkHStrXY(3,17,0,0,'Yellow player [#3] ('   +#18+'R'+#25+')');
   _mkHStrXY(3,18,0,0,'Green player [#4] ('    +#18+'T'+#25+')');
   _mkHStrXY(3,19,0,0,'Aqua player [#5] ('     +#18+'Y'+#25+')');
   _mkHStrXY(3,20,0,0,'Blue player [#6] ('     +#18+'F'+#25+')');
   {


   str_hint[0,r_uac ,21] := 'Mines';
   str_hint[0,r_hell,21] := 'Zombie ('+#18+'M'+#25+')'+#11+#17+str_req+#25+'Hell '+str_un_name[UID_UMilitaryUnit];
   str_hint[0,r_hell,22] := 'Hell Eye';

   str_hint[0,r_uac ,24] := 'Action ('        +#18+'Ctrl'+#25+'+'+#18+'Space'+#25+')';
   str_hint[0,r_uac ,25] := 'Destroy ('       +#18+'Delete'+#25+')';
   str_hint[0,r_uac ,26] := 'Cancle ('        +#18+'Space'+#25+')';
   str_hint[1,r_uac ,27] := 'Menu ('          +#18+'Esc'+#25+')';
   str_hint[0,r_hell,24] := str_hint[0,r_uac ,24];
   str_hint[0,r_hell,25] := str_hint[0,r_uac ,25];
   str_hint[0,r_hell,26] := str_hint[0,r_uac ,26];
   str_hint[0,r_hell,27] := str_hint[0,r_uac ,27];
   str_hint[1,r_hell,27] := str_hint[1,r_uac ,27]; }

   str_camp_t[0]         := 'Hell #1: Phobos invasion';
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
   str_camp_m[7]         := #18+'Date:'+#25+#12+'19.11.2145'+#12+#18+'Location:'+#25+#12+'EARTH' +#12+#18+'Area:'+#25+#12+'Unknown';

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
begin
  str_MMap              := '�����';
  str_MPlayers          := '������';
  str_MObjectives       := '������';
  str_menu_s1[ms1_sett] := '���������';
  str_menu_s1[ms1_svld] := '����./����.';
  str_menu_s1[ms1_reps] := '������';
  str_menu_s2[ms2_camp] := '��������';
  str_menu_s2[ms2_scir] := '�������';
  str_menu_s2[ms2_mult] := '������� ����';
  str_menu_s3[ms3_game] := '����';
  str_menu_s3[ms3_vido] := '�������';
  str_menu_s3[ms3_sond] := '����';
  str_reset[false]      := '������';
  str_reset[true ]      := '�����';
  str_exit[false]       := '�����';
  str_exit[true]        := '�����';
  str_m_liq             := '�����: ';
  str_m_siz             := '������: ';
  str_m_obs             := '��������: ';
  str_map               := '�����';
  str_players           := '������';
  str_mrandom           := '��������� �����';
  str_musicvol          := '��������� ������';
  str_soundvol          := '��������� ������';
  str_scrollspd         := '�������� ��.';
  str_mousescrl         := '�����. �����:';
  str_fullscreen        := '� ����:';
  str_plname            := '��� ������';
  str_maction           := '������ ����';
  str_maction2[true ]   := #18+'��������'+#25;
  str_maction2[false]   := #17+'��������'+#25+'+'+#17+'�����'+#25;
  str_race[r_random]    := #22+'����.'+#25;
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
  str_player_def        := ' ���������!';
  str_inv_time          := '����� #';
  str_inv_ml            := '�������: ';
  str_play              := '���������';
  str_replay            := '������';
  str_cmpdif            := '���������: ';
  str_waitsv            := '�������� �������...';
  str_goptions          := '��������� ����';
  str_server            := '������';
  str_client            := '������';
  str_chat              := '���';
  str_gaddon            := '����:';
  str_randoms           := '��������� �������';
  str_apply             := '���������';
  str_plout             := ' ������� ����';
  str_aislots           := '��������� ������ �����:';
  str_chattars          := '���������� ���������';
  str_resol             := '����������';
  str_language          := '���� ����������';
  str_req               := '����������: ';
  str_orders            := '������: ';
  str_all               := '���';

  str_starta            := '��������� ����:';
  str_startat[0]        := '1 '+#19+'���������'+#25;
  str_startat[1]        := '1 '+#19+'���������'+#25+'+ 1 '+#18+'���.'+#25;
  str_startat[2]        := '1 '+#19+'���������'+#25+'+ 2 '+#18+'���.'+#25;
  str_startat[3]        := '1 '+#19+'���.'+#25+'+ 2 '+#18+'���.'+#25+'+ 2 '+#17+'�.'+#25;
  str_startat[4]        := '2 '+#19+'���������'+#25;
  str_startat[5]        := '1 '+#19+'���.'+#25+'+ 100 �������';

  str_sstarts           := '���������� ������:';

  str_gmodet            := '����� ����:';
  str_gmode[gm_scir ]   := #18+'�������'+#25;
  str_gmode[gm_2fort]   := #16+'��� ��������'+#25;
  str_gmode[gm_3fort]   := #17+'��� ��������'+#25;
  str_gmode[gm_ct   ]   := #19+'������ �����'+#25;
  str_gmode[gm_inv  ]   := #20+'���������'+#25;
  str_gmode[gm_coop ]   := #15+'�����'+#25;

  str_team              := '����:';
  str_srace             := '����:';
  str_ready             := '�����: ';
  str_udpport           := 'UDP ����:';
  str_svup[false]       := '���. ������';
  str_svup[true ]       := '����. ������';
  str_connect[false]    := '�����������';
  str_connect[true ]    := '����.';
  str_pnu               := '������/��������:';
  str_npnu              := '���������� ������: ';
  str_connecting        := '����������...';
  str_sver              := '������ ������!';
  str_sfull             := '��� ����!';
  str_sgst              := '���� ��������!';

  str_hint_t[0]         := '������';
  str_hint_t[1]         := '�����';
  str_hint_t[2]         := '������������';
  str_hint_t[3]         := '������';

  str_hint_m[0]         := '���� ('          +#18+'Esc'+#25+')';
  str_hint_m[2]         := '����� ('         +#18+'Pause/Break'+#25+')';

  _mkHStr(0,r_hell,0 ,'������ ��������'      ,'������ ����.'                          );
  _mkHStr(0,r_hell,1 ,'������ �����'         ,'��������� ������.'                      );
  _mkHStr(0,r_hell,2 ,'������ ������'        ,'���������� �������.'                   );
  _mkHStr(0,r_hell,3 ,'������ �����'         ,'��������� ���������.'                  );
  _mkHStr(0,r_hell,4 ,'������ �����'         ,'�������� ����������.'                  );
  _mkHStr(0,r_hell,5 ,'������ ��������'      ,'���������� ������ � ����� ����� �����.');
  _mkHStr(0,r_hell,6 ,'������ ���������'     ,'�������� ������.'                      );
  _mkHStr(0,r_hell,7 ,'������ �����'         ,'����������� �������� ����������.'      );
  _mkHStr(0,r_hell,8 ,'������ ������'        ,'�������� ������ ������ �����������.'   );

  _mkHStr(2,r_hell,upgr_attack  ,'��������� ������� �����'        ,''                                         );
  _mkHStr(2,r_hell,upgr_armor   ,'��������� ������ ������'        ,''                                         );
  _mkHStr(2,r_hell,upgr_build   ,'��������� ������ ������'        ,''                                         );
  _mkHStr(2,r_hell,upgr_melee   ,'��������� ������� �����'        ,''                                         );
  _mkHStr(2,r_hell,upgr_regen   ,'�����������'                    ,'������� ����� �������� ��������������� ���� ��������.'                   );
  _mkHStr(2,r_hell,upgr_pains   ,'������� �����'                  ,'��������� ���� "pain state".'                                            );
  _mkHStr(2,r_hell,upgr_vision  ,'������ ����'                    ,'����������� Lost Soul � ������ ������ ������� �����.'                    );
  _mkHStr(2,r_hell,upgr_towers  ,'������ ����� �����'             ,'���������� ������� ����� � ������ �������� ����������.'                  );
  _mkHStr(2,r_hell,upgr_5bld    ,'��������� ���������'            ,'��������� ����� ����������� ���������.'                                  );
  _mkHStr(2,r_hell,upgr_mainm   ,'������������ ������ ��������'   ,'������ �������� ����� ������������ � ����� ��������� ����� �����.'       );
  _mkHStr(2,r_hell,upgr_paina   ,'���� ����������'                ,'������ �������� ������� ���� ���� ������ ������.'                        );
  _mkHStr(2,r_hell,upgr_mainr   ,'������ ������ ������ ��������'  ,'����������� ������ ������ � ��������� ������������� ��� A����� ��������.');
  _mkHStr(2,r_hell,upgr_pinkspd ,'������ ������'                  ,'���������� �������� ����� Demon.'                                        );
  _mkHStr(2,r_hell,upgr_6bld    ,'����� ����'                     ,'��������� ������� ��������� �������� ����� ������.'                      );
  _mkHStr(2,r_hell,upgr_misfst  ,'������� ����'                   ,'����������� �������� ������ �������� ������ Imp, Cacodemon � Baron of Hell/Hell Knight.'                              );
  _mkHStr(2,r_hell,upgr_2tier   ,'������� ���'                    ,'������ ������� ������, ������ � ���������.'                              );
  _mkHStr(2,r_hell,upgr_revtele ,'�������� ��������'              ,'����� ����� ������������ ������� � ������ ��������.'                     );
  _mkHStr(2,r_hell,upgr_revmis  ,'��������� ����� ����� Revenant' ,'������� ���������� ����������������.'                                    );
  _mkHStr(2,r_hell,upgr_totminv ,'����������� ��� ������ � �����' ,'������ ����� � ���� ���������� ����������.'                              );
  _mkHStr(2,r_hell,upgr_bldrep  ,'�������������� ������'          ,'������������ ������ �������� ��������������� ����.'                      );
  _mkHStr(2,r_hell,upgr_mainonr ,'��������� ������������'         ,'������ �������� ����� ������������ �� �����, ����� � ��. �����������.'   );
  _mkHStr(2,r_hell,upgr_b478tel ,'������������ �� �������� ���������'
                                                                  ,'������ �������, ����� � ������ ����� ����������������� �� �������� ����������.');
  _mkHStr(2,r_hell,upgr_hinvuln ,'������������'                   ,'����� ������������ ��� ������� ������.'                                  );
  _mkHStr(2,r_hell,upgr_bldenrg ,'��������� ������ ������'        ,'�������������� ������� ��� ������ ��������.'                             );


  _mkHStr(0,r_uac,0 ,'��������� �����'        ,'������ ����.'                    );
  _mkHStr(0,r_uac,1 ,'��������� �����'        ,'��������� ������.'               );
  _mkHStr(0,r_uac,2 ,'���������'              ,'���������� �������.'             );
  _mkHStr(0,r_uac,3 ,'����� ����������'       ,'��������� ���������.'            );
  _mkHStr(0,r_uac,4 ,'���������� ������'      ,'�������� ����������.'            );
  _mkHStr(0,r_uac,5 ,'�����'                  ,'���������� �����.'               );
  _mkHStr(0,r_uac,6 ,'����������� �����'      ,'�������� ������.'                );
  _mkHStr(0,r_uac,7 ,'���������� ������'      ,'����������� �������� ����������.');
  _mkHStr(0,r_uac,8 ,'������� ��������� �����','���������� �������� ����. ��� ����� ��������� ������������ "�������� ����".');

  _mkHStr(1,r_uac,0 ,'�������'            ,'');
  _mkHStr(1,r_uac,1 ,'�����'              ,'');
  _mkHStr(1,r_uac,2 ,'�������'            ,'');
  _mkHStr(1,r_uac,3 ,'��������'           ,'');
  _mkHStr(1,r_uac,4 ,'�������������'      ,'');
  _mkHStr(1,r_uac,5 ,'�����'              ,'');
  _mkHStr(1,r_uac,6 ,'������ � BFG'       ,'');
  _mkHStr(1,r_uac,7 ,'��������� ���������','');
  _mkHStr(1,r_uac,8 ,'���'                ,'');
  _mkHStr(1,r_uac,9 ,'����������'         ,'');
  _mkHStr(1,r_uac,10,'����'               ,'');
  _mkHStr(1,r_uac,11,'�����������'        ,'');

  _mkHStr(2,r_uac ,upgr_attack  ,'��������� ������� �����'  ,''                                );
  _mkHStr(2,r_uac ,upgr_armor   ,'��������� ������ ������'  ,''                                );
  _mkHStr(2,r_uac ,upgr_build   ,'��������� ������ ������'  ,''                                );
  _mkHStr(2,r_uac ,upgr_melee   ,'������ � �������'         ,'���������� ������������� ������� ��������� � ������� �������.');
  _mkHStr(2,r_uac ,upgr_mspeed  ,'����������� �����'        ,'���������� �������� ������������ ������.'                 );
  _mkHStr(2,r_uac ,upgr_plsmt   ,'������ �� ����������'     ,'������ ��� ��������������.'                               );
  _mkHStr(2,r_uac ,upgr_vision  ,'���������'                ,'����� � ���� ���������� �����������.'                     );
  _mkHStr(2,r_uac ,upgr_towers  ,'������ ����� �������'     ,'���������� ������� ����� � ������ �������� ����������.'   );
  _mkHStr(2,r_uac ,upgr_5bld    ,'��������� ������'         ,'����������� ������ � ����� �������� ������.'              );
  _mkHStr(2,r_uac ,upgr_mainm   ,'��������� ���������� ������','��������� ����� ����� ������.'                          );
  _mkHStr(2,r_uac ,upgr_ucomatt ,'������ ���������� ������' ,'�������� ��������� ����� ����� ���������.'                );
  _mkHStr(2,r_uac ,upgr_mainr   ,'������ ������ ���������� ������','����������� ������ ������ � ��������� ������������� ���������� ������.');
  _mkHStr(2,r_uac ,upgr_mines   ,'����'                     ,'����������� ��������.'                                    );
  _mkHStr(2,r_uac ,upgr_minesen ,'����-������'              ,'����������� ���.'                                         );
  _mkHStr(2,r_uac ,upgr_6bld    ,'�������������� ����������','����������� ����� ����� �������� ������.'                 );
  _mkHStr(2,r_uac ,upgr_2tier   ,'������ ����������'        ,'������ ������� ������, ������ � ���������.'               );
  _mkHStr(2,r_uac ,upgr_blizz   ,'�������� ����'            ,'������ ��� ������� ��������� �����.'                      );
  _mkHStr(2,r_uac ,upgr_mechspd ,'����������� ���������'    ,'����������� �������� ������������ �������.'               );
  _mkHStr(2,r_uac ,upgr_mecharm ,'��������� ������ �������' ,''                             );
  _mkHStr(2,r_uac ,upgr_6bld2   ,'������� ��������������'   ,'���������� ������� ����������� ������������ ������ ��� ��������� ������.');
  _mkHStr(2,r_uac ,upgr_mainonr ,'��������� �����������'    ,'��������� ����� ����� ������������ �� �����, ����� � ��. �����������.');
  _mkHStr(2,r_uac ,upgr_turarm  ,'������ ��� �������'       ,'�������������� ���������� ������ �������.'                );
  _mkHStr(2,r_uac ,upgr_rturrets,'�������� ������'          ,'������� ������ ����� ���� �������� �� ��������.'          );
  _mkHStr(2,r_uac ,upgr_bldenrg ,'���������� ���������'     ,'������������� ������� ��� ���������� ������.'             );


  _mkHStrXY(3,9 ,0,0,'��������/��������� ���������� �������� ('+#18+'Q'+#25+')');
  _mkHStrXY(3,10,0,0,'����� ����: ���������� 2 ������� ('+#18+'W'+#25+')'+#11+'������ ����: ���������� 10 ������ ('+#18+'Ctrl'+#25+'+'+#18+'W'+#25+')');
  _mkHStrXY(3,11,0,0,'����� ('                   +#18+'E'+#25+')');
  _mkHStrXY(3,12,0,0,'����� ����� ('             +#18+'A'+#25+')');
  _mkHStrXY(3,13,0,0,'������ ������� ��������� ('+#18+'S'+#25+')');
  _mkHStrXY(3,14,0,0,'��� ������ ('              +#18+'Z'+#25+')');
  _mkHStrXY(3,15,0,0,'������� ����� [#1] ('      +#18+'X'+#25+')');
  _mkHStrXY(3,16,0,0,'��������� ����� [#2] ('    +#18+'C'+#25+')');
  _mkHStrXY(3,17,0,0,'������ ����� [#3] ('       +#18+'R'+#25+')');
  _mkHStrXY(3,18,0,0,'������� ����� [#4] ('      +#18+'T'+#25+')');
  _mkHStrXY(3,19,0,0,'��������� ����� [#5] ('    +#18+'Y'+#25+')');
  _mkHStrXY(3,20,0,0,'����� ����� [#6] ('        +#18+'F'+#25+')');

 {
  str_hint[0,r_uac ,21] := '����';
  str_hint[0,r_hell,21] := '����� ('+#18+'M'+#25+')'+#11+#17+str_req+#25+'������ '+str_un_name[UID_UMilitaryUnit];
  str_hint[0,r_hell,22] := '������ ����';

  str_hint[0,r_hell,24] := '�������� ('      +#18+'Ctrl'+#25+'+'+#18+'Space'+#25+')';
  str_hint[0,r_hell,25] := '���������� ('    +#18+'Delete'+#25+')';
  str_hint[0,r_hell,26] := '������ ('        +#18+'Space'+#25+')';
  str_hint[1,r_hell,27] := '���� ('          +#18+'Esc'+#25+')';
  str_hint[0,r_uac ,24] := str_hint[0,r_hell,24];
  str_hint[0,r_uac ,25] := str_hint[0,r_hell,25];
  str_hint[0,r_uac ,26] := str_hint[0,r_hell,26];
  str_hint[0,r_uac ,27] := str_hint[0,r_hell,27];
  str_hint[1,r_uac ,27] := str_hint[1,r_hell,27]; }

  str_camp_t[0]         := 'Hell #1: ��������� �� �����';
  str_camp_t[1]         := 'Hell #2: ������� ����';
  str_camp_t[2]         := 'Hell #3: ��������� �� ������';
  str_camp_t[3]         := 'Hell #4: ����������� ������';
  str_camp_t[4]         := 'Hell #7: ������';
  str_camp_t[5]         := 'Hell #8: �� �� �����';
  str_camp_t[6]         := 'Hell #5: �� �� �����';
  str_camp_t[7]         := 'Hell #6: ���������';

  str_camp_o[0]         := '-�������� ��� ������� ���� � �����'+#13+'-������ ������';
  str_camp_o[1]         := '-�������� ������� ����';
  str_camp_o[2]         := '-�������� ��� ������� ���� � �����'+#13+'-������ ������';
  str_camp_o[3]         := '-������ ������ � ������� 20 �����';
  str_camp_o[4]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[5]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[6]         := '-�������� ��� ������� ���� � �����';
  str_camp_o[7]         := '-�������� ���������'+#13+'-�� ���� ������� ��������� �� ������'+#13+'����';

  str_camp_m[0]         := #18+'����:'+#25+#12+'15.11.2145'+#12+#18+'�����:'+#25+#12+'�����' +#12+#18+'�����:'+#25+#12+'��������';
  str_camp_m[1]         := #18+'����:'+#25+#12+'16.11.2145'+#12+#18+'�����:'+#25+#12+'�����' +#12+#18+'�����:'+#25+#12+'������ ����';
  str_camp_m[2]         := #18+'����:'+#25+#12+'15.11.2145'+#12+#18+'�����:'+#25+#12+'������'+#12+#18+'�����:'+#25+#12+'��������';
  str_camp_m[3]         := #18+'����:'+#25+#12+'16.11.2145'+#12+#18+'�����:'+#25+#12+'������'+#12+#18+'�����:'+#25+#12+'������ �����';
  str_camp_m[4]         := #18+'����:'+#25+#12+'18.11.2145'+#12+#18+'�����:'+#25+#12+'����'  +#12+#18+'�����:'+#25+#12+'������� ������';
  str_camp_m[5]         := #18+'����:'+#25+#12+'19.11.2145'+#12+#18+'�����:'+#25+#12+'����'  +#12+#18+'�����:'+#25+#12+'������� ������';
  str_camp_m[6]         := #18+'����:'+#25+#12+'18.11.2145'+#12+#18+'�����:'+#25+#12+'�����' +#12+#18+'�����:'+#25+#12+'����������';
  str_camp_m[7]         := #18+'����:'+#25+#12+'19.11.2145'+#12+#18+'�����:'+#25+#12+'�����' +#12+#18+'�����:'+#25+#12+'����������';

  _makeHints;
end;


procedure swLNG;
begin
  if(_lng)
  then lng_rus
  else lng_eng;
end;



