

function loadMSC(fn:string):pMIX_MUSIC;
begin
   fn:=str_f_msc+fn+#0;
   loadMSC:=MIX_LOADMUS(@fn[1]);
end;

function MIXChunkGetFPSLength(s:pMIX_CHUNK):integer;
var format:word;
  freq,
  channels:LongInt;
  tmp:single;
begin
   freq    :=0;
   format  :=0;
   channels:=0;
   Mix_QuerySpec(freq,format,channels);

   MIXChunkGetFPSLength:=0;

   if(channels=0)
   or(freq    =0)then exit;

   tmp :=(format and $FF)/8;
   if(tmp=0)then exit;
   tmp:=s^.alen/tmp;

   MIXChunkGetFPSLength:=trunc( ((tmp/channels)/freq)*fr_fps );
end;

function LoadChunk(fn:shortstring):pMIX_Chunk;
var n:shortstring;
begin
   n:=str_f_snd+fn+'.wav'+#0;
   LoadChunk:=mix_loadwav(@n[1]);
end;

function loadSND(fn:shortstring):PTMWSound;
var t:pMIX_Chunk;
begin
   loadSND:=nil;
   t := LoadChunk(fn);
   if(t<>nil)then
   begin
      new(loadSND);
      with loadSND^ do
      begin
         sound:=t;
         ticks_length:=MIXChunkGetFPSLength(t);
         last_channel:=-1;
      end;
   end;
end;

procedure AddToSoundSet(ss:PTSoundSet;tsnd:PTMWSound);
begin
   if(tsnd<>nil)then
   with ss^ do
   begin
      inc(sndn,1);
      setlength(snds,sndn);
      snds[sndn-1]:=tsnd;
   end;
end;

function LoadSoundSet(fname:shortstring):PTSoundSet;
var tsnd:PTMWSound;
       i:integer;
begin
   i:=0;
   new(LoadSoundSet);
   with LoadSoundSet^ do
   begin
      sndps:=0;
      sndn :=0;
      setlength(snds,sndn);

      tsnd:=loadSND(fname);
      if(tsnd<>nil)then AddToSoundSet(LoadSoundSet,tsnd);

      while true do
      begin
         tsnd:=loadSND(fname+i2s(i));
         if(tsnd=nil)then
          if(i=0)then
          begin
             inc(i,1);
             continue;
          end
          else break;

         AddToSoundSet(LoadSoundSet,tsnd);
         inc(i,1);
      end;
      if(sndn=0)then WriteLog(fname);
   end;
end;

procedure PlayMSC(m:pMIX_MUSIC);
begin
   MIX_PLAYMUSIC(m,0);
   MIX_VOLUMEMUSIC(snd_mvolume);
end;

procedure _MusicCheck;
begin
   if(snd_music_list_size>0)then
    if(Mix_PlayingMusic>0)then
    begin
       if(G_started)and(snd_current_music=0)and(snd_music_list_size>1)then
       begin
          snd_current_music:=1+random(snd_music_list_size-1);
          PlayMSC(snd_music_list[snd_current_music]);
       end
       else
         if(G_started=false)and(snd_current_music>0)then
         begin
            snd_current_music:=0;
            PlayMSC(snd_music_list[snd_current_music]);
         end;
    end
    else
    begin
       if(G_started)and(snd_music_list_size>1)then
       begin
          inc(snd_current_music,1);
          if(snd_current_music>=snd_music_list_size)then snd_current_music:=1;
       end
       else snd_current_music:=0;
       PlayMSC(snd_music_list[snd_current_music]);
    end;
end;

function SoundSet2Chunk(ss:PTSoundSet):PTMWSound;
begin
   SoundSet2Chunk:=nil;
   with ss^ do
    if(sndn>0)then
     if(sndn=1)
     then SoundSet2Chunk:=snds[0]
     else
     begin
        inc(sndps,1);
        if(sndps<0)or(sndps>=sndn)then sndps:=0;
        SoundSet2Chunk:=snds[sndps];
     end;
end;

function PlaySound(Sound:PTMWSound):integer;
begin
   PlaySound:=-1;
   if(Sound<>nil)then
   with Sound^ do
   begin
      MIX_VOLUMECHUNK(sound,snd_svolume);
      PlaySound:=MIX_PLAYCHANNEL(-1,sound,0);
   end;
end;

function PlaySoundSet(ss:PTSoundSet;channel:pinteger):PTMWSound;
var i:integer;
begin
   PlaySoundSet:=SoundSet2Chunk(ss);

   if(channel<>nil)then
    if(channel^>-1)then MIX_HALTCHANNEL(channel^);

   i:=PlaySound(PlaySoundSet);
   if(channel<>nil)then channel^:=i;
end;

function PlaySND(ss:PTSoundSet;pu:PTUnit;visdata:pboolean):boolean;
begin
   PlaySND:=false;

   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(visdata<>nil)then
   begin
      if(visdata^=false)then exit;
   end
   else
     if(pu<>nil)then
      with pu^ do
       if(_nhp3(x,y,player)=false)then exit;

   PlaySoundSet(ss,nil);
   PlaySND:=true;
end;

procedure PlaySNDM(ss:PTSoundSet);
begin
   if(ss=nil)
   or(_draw=false)then exit;

   PlaySoundSet(ss,nil);
end;

procedure PlayInGameAnoncer(ss:PTSoundSet);
const min_snd_pause = fr_hhfps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(snd_anoncer_pause<=min_snd_pause)or(snd_anoncer_last<>ss)then
   begin
      s:=PlaySoundSet(ss,@snd_anoncer_channel);
      if(s<>nil)then
      begin
         snd_anoncer_last :=ss;
         snd_anoncer_pause:=max2(min_snd_pause,s^.ticks_length);
      end;
   end;
end;

procedure PlayCommandSound(ss:PTSoundSet);
const min_snd_pause = fr_hfps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(snd_unitcmd_pause<=min_snd_pause)or(snd_unitcmd_last<>ss)then
   begin
      s:=PlaySoundSet(ss,@snd_unitcmd_channel);
      if(s<>nil)then
      begin
         snd_unitcmd_last :=ss;
         snd_unitcmd_pause:=max2(min_snd_pause,s^.ticks_length);
      end;
   end;
end;

procedure PlayUnitSelect;
const annoystart = 6;
      annoystop  = 12;
begin
   if(ui_UnitSelectedNU>0)then
   begin
      if(ui_UnitSelectedNU<>ui_UnitSelectedPU)
      then ui_UnitSelectedn:=0
      else
        if(ui_UnitSelectedn<annoystop)
        then inc(ui_UnitSelectedn,1)
        else ui_UnitSelectedn:=0;

      with _units[ui_UnitSelectedNU] do
      with uid^ do
       if(_isbuilding)and(bld=false)
       then PlayCommandSound(snd_building[_urace])
       else
        if(ui_UnitSelectedn<annoystart)
        then PlayCommandSound(un_snd_select[buff[ub_advanced]>0])
        else PlayCommandSound(un_snd_annoy [buff[ub_advanced]>0]);

      ui_UnitSelectedPU:=ui_UnitSelectedNU;
      ui_UnitSelectedNU:=0;
   end;
end;

procedure LoadMusicMask(mask:shortstring);
var Info : TSearchRec;
       s : shortstring;
begin
   if(FindFirst(str_f_msc+mask,faReadonly,info)=0)then
   repeat
      s:=info.Name;
      if(s<>'')then
      begin
         setlength(snd_music_list,snd_music_list_size+1);
         snd_music_list[snd_music_list_size]:=loadMSC(s);
         Inc(snd_music_list_size,1);
      end;
   until (FindNext(info)<>0);
   FindClose(info);
end;

procedure LoadAllMusic;
begin
   snd_music_list_size:=0;
   setlength(snd_music_list,0);

   LoadMusicMask('*.ogg');
   LoadMusicMask('*.wav');
end;

procedure ShafleMusicList;
var i,m1,m2:byte;
    d:pMIX_MUSIC;
begin
   if(snd_music_list_size>3)then
    for i:=1 to snd_music_list_size do
    begin
       m1:=random(snd_music_list_size-1)+1;
       m2:=random(snd_music_list_size-1)+1;
       d:=snd_music_list[m1];
       snd_music_list[m1]:=snd_music_list[m2];
       snd_music_list[m2]:=d;
    end;
end;


function InitSound:boolean;
var r:byte;
begin
   InitSound:=false;

   if(SDL_Init(SDL_INIT_AUDIO)<>0)then begin WriteSDLError; exit; end;

   if(MIX_OPENAUDIO(AUDIO_FREQUENCY,
                    AUDIO_FORMAT,
                    AUDIO_CHANNELS,
                    AUDIO_CHUNKSIZE)<>0) then begin WriteSDLError; exit; end;

   LoadAllMusic;
   ShafleMusicList;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // COMMON
   //

   snd_click                :=LoadSoundSet('click'           );
   snd_chat                 :=LoadSoundSet('chat'            );
   snd_building_explode     :=LoadSoundSet('building_explode');
   snd_teleport             :=LoadSoundSet('teleport'        );
   snd_exp                  :=LoadSoundSet('explode'         );
   snd_mine_place           :=LoadSoundSet('mine_place'      );
   snd_inapc                :=LoadSoundSet('inapc'           );
   snd_meat                 :=LoadSoundSet('meat'            );

   snd_pexp                 :=LoadSoundSet(missiles_folder+'p_exp'           );
   snd_launch               :=LoadSoundSet(missiles_folder+'launch'          );
   snd_pistol               :=LoadSoundSet(missiles_folder+'pistol'          );
   snd_shotgun              :=LoadSoundSet(missiles_folder+'shotgun'         );
   snd_ssg                  :=LoadSoundSet(missiles_folder+'ssg'             );
   snd_plasma               :=LoadSoundSet(missiles_folder+'plasma'          );
   snd_bfg_shot             :=LoadSoundSet(missiles_folder+'bfg_shot'        );
   snd_healing              :=LoadSoundSet(missiles_folder+'healing'         );
   snd_electro              :=LoadSoundSet(missiles_folder+'electro'         );
   snd_rico                 :=LoadSoundSet(missiles_folder+'rico'            );
   snd_bfg_exp              :=LoadSoundSet(missiles_folder+'bfg_exp'         );
   snd_flyer_s              :=LoadSoundSet(missiles_folder+'flyer_s'         );
   snd_flyer_a              :=LoadSoundSet(missiles_folder+'flyer_a'         );

   for r:=1 to r_cnt do
   begin
   snd_under_attack[true ,r]:=LoadSoundSet(race_dir[r]+'base_under_attack'         );
   snd_under_attack[false,r]:=LoadSoundSet(race_dir[r]+'unit_under_attack'         );
   snd_build_place       [r]:=LoadSoundSet(race_dir[r]+'build_place'               );
   snd_building          [r]:=LoadSoundSet(race_dir[r]+'building'                  );
   snd_constr_complete   [r]:=LoadSoundSet(race_dir[r]+'construction_complete'     );
   snd_cannot_build      [r]:=LoadSoundSet(race_dir[r]+'cannot_build_here'         );
   snd_defeat            [r]:=LoadSoundSet(race_dir[r]+'defeat'                    );
   snd_not_enough_energy [r]:=LoadSoundSet(race_dir[r]+'not_enough_energy'         );
   snd_player_defeated   [r]:=LoadSoundSet(race_dir[r]+'player_defeated'           );
   snd_upgrade_complete  [r]:=LoadSoundSet(race_dir[r]+'upgrade_complete'          );
   snd_victory           [r]:=LoadSoundSet(race_dir[r]+'victory'                   );
   snd_unit_adv          [r]:=LoadSoundSet(race_dir[r]+'unit_adv'                  );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_radar                :=LoadSoundSet(race_dir[r_uac]+'radar');

   snd_jetpoff              :=LoadSoundSet(race_dir[r_uac]+'jetpoff');
   snd_jetpon               :=LoadSoundSet(race_dir[r_uac]+'jetpon' );

   snd_uac_cc               :=LoadSoundSet(race_buildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=LoadSoundSet(race_buildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=LoadSoundSet(race_buildings[r_uac ]+'generator'      );
   snd_uac_smith            :=LoadSoundSet(race_buildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=LoadSoundSet(race_buildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=LoadSoundSet(race_buildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=LoadSoundSet(race_buildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=LoadSoundSet(race_buildings[r_uac ]+'factory'        );
   snd_uac_tech             :=LoadSoundSet(race_buildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=LoadSoundSet(race_buildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=LoadSoundSet(race_buildings[r_uac ]+'nuclear_plant'  );

   snd_uac_suply            :=LoadSoundSet(race_buildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=LoadSoundSet(race_buildings[r_uac ]+'resourse_senter');

   snd_uac_hdeath           :=LoadSoundSet(race_units[r_uac ]+'death'              );

   snd_APC_ready            :=LoadSoundSet(race_units[r_uac ]+'APC\UAC_im_find2'   );
   snd_APC_move             :=LoadSoundSet(race_units[r_uac ]+'APC\uac_u'          );

   snd_bfgmarine_ready      :=LoadSoundSet(race_units[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=LoadSoundSet(race_units[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=LoadSoundSet(race_units[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=LoadSoundSet(race_units[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=LoadSoundSet(race_units[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=LoadSoundSet(race_units[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=LoadSoundSet(race_units[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=LoadSoundSet(race_units[r_uac ]+'commando\attack'    );
   snd_commando_select      :=LoadSoundSet(race_units[r_uac ]+'commando\select'    );
   snd_commando_move        :=LoadSoundSet(race_units[r_uac ]+'commando\move'      );

   snd_engineer_ready       :=LoadSoundSet(race_units[r_uac ]+'engineer\ready'     );
   snd_engineer_annoy       :=LoadSoundSet(race_units[r_uac ]+'engineer\annoy'     );
   snd_engineer_attack      :=LoadSoundSet(race_units[r_uac ]+'engineer\attack'    );
   snd_engineer_select      :=LoadSoundSet(race_units[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=LoadSoundSet(race_units[r_uac ]+'engineer\move'      );

   snd_medic_ready          :=LoadSoundSet(race_units[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=LoadSoundSet(race_units[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=LoadSoundSet(race_units[r_uac ]+'medic\select'       );
   snd_medic_move           :=LoadSoundSet(race_units[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=LoadSoundSet(race_units[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=LoadSoundSet(race_units[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=LoadSoundSet(race_units[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=LoadSoundSet(race_units[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=LoadSoundSet(race_units[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=LoadSoundSet(race_units[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=LoadSoundSet(race_units[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=LoadSoundSet(race_units[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=LoadSoundSet(race_units[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=LoadSoundSet(race_units[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=LoadSoundSet(race_units[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=LoadSoundSet(race_units[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=LoadSoundSet(race_units[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=LoadSoundSet(race_units[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=LoadSoundSet(race_units[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=LoadSoundSet(race_units[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=LoadSoundSet(race_units[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=LoadSoundSet(race_units[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=LoadSoundSet(race_units[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=LoadSoundSet(race_units[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=LoadSoundSet(race_units[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=LoadSoundSet(race_units[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=LoadSoundSet(race_units[r_uac ]+'tank\attack'        );
   snd_tank_select          :=LoadSoundSet(race_units[r_uac ]+'tank\select'        );
   snd_tank_move            :=LoadSoundSet(race_units[r_uac ]+'tank\move'          );

   snd_terminator_ready     :=LoadSoundSet(race_units[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=LoadSoundSet(race_units[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=LoadSoundSet(race_units[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=LoadSoundSet(race_units[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=LoadSoundSet(race_units[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=LoadSoundSet(race_units[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=LoadSoundSet(race_units[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=LoadSoundSet(race_units[r_uac ]+'transport\select'   );
   snd_transport_move       :=LoadSoundSet(race_units[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=LoadSoundSet(race_units[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=LoadSoundSet(race_units[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=LoadSoundSet(race_units[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=LoadSoundSet(race_units[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=LoadSoundSet(race_units[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=LoadSoundSet(race_buildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=LoadSoundSet(race_buildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=LoadSoundSet(race_buildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=LoadSoundSet(race_buildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=LoadSoundSet(race_buildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=LoadSoundSet(race_buildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=LoadSoundSet(race_buildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=LoadSoundSet(race_buildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=LoadSoundSet(race_buildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=LoadSoundSet(race_buildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=LoadSoundSet(race_buildings[r_hell]+'hell_building' );
   snd_hell_eye             :=LoadSoundSet(race_buildings[r_hell]+'hell_eye'      );



   snd_hell_invuln          :=LoadSoundSet(race_units[r_hell]+'invuln');
   snd_hell_pain            :=LoadSoundSet(race_units[r_hell]+'d_p');
   snd_hell_melee           :=LoadSoundSet(race_units[r_hell]+'d_m');
   snd_hell_attack          :=LoadSoundSet(race_units[r_hell]+'d_a');
   snd_hell_move            :=LoadSoundSet(race_units[r_hell]+'d_' );

   snd_zimba_death          :=LoadSoundSet(race_units[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=LoadSoundSet(race_units[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=LoadSoundSet(race_units[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=LoadSoundSet(race_units[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=LoadSoundSet(race_units[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=LoadSoundSet(race_units[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=LoadSoundSet(race_units[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=LoadSoundSet(race_units[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=LoadSoundSet(race_units[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=LoadSoundSet(race_units[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=LoadSoundSet(race_units[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=LoadSoundSet(race_units[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=LoadSoundSet(race_units[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=LoadSoundSet(race_units[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=LoadSoundSet(race_units[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=LoadSoundSet(race_units[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=LoadSoundSet(race_units[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=LoadSoundSet(race_units[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=LoadSoundSet(race_units[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=LoadSoundSet(race_units[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=LoadSoundSet(race_units[r_hell]+'knight\knightc');
   snd_knight_death         :=LoadSoundSet(race_units[r_hell]+'knight\knightd');
   snd_baron_ready          :=LoadSoundSet(race_units[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=LoadSoundSet(race_units[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=LoadSoundSet(race_units[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=LoadSoundSet(race_units[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=LoadSoundSet(race_units[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=LoadSoundSet(race_units[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=LoadSoundSet(race_units[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=LoadSoundSet(race_units[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=LoadSoundSet(race_units[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=LoadSoundSet(race_units[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=LoadSoundSet(race_units[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=LoadSoundSet(race_units[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=LoadSoundSet(race_units[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=LoadSoundSet(race_units[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=LoadSoundSet(race_units[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=LoadSoundSet(race_units[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=LoadSoundSet(race_units[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=LoadSoundSet(race_units[r_hell]+'arachnotron\d_ar_c');


  {snd_inapc       :=loadSND('inapc.wav'    );
   snd_ccup        :=loadSND('ccup.wav'     );

   snd_meat        :=loadSND('gv.wav'       );
   snd_d0          :=loadSND('d_u0.wav'     );
   snd_ar_act      :=loadSND('d_ar_act.wav' );
   snd_ar_d        :=loadSND('d_ar_d.wav'   );
   snd_ar_c        :=loadSND('d_ar_c.wav'   );
   snd_ar_f        :=loadSND('d_ar_f.wav'   );
   snd_arch_a      :=loadSND('d_arch_a.wav' );
   snd_arch_at     :=loadSND('d_arch_at.wav');
   snd_arch_d      :=loadSND('d_arch_d.wav' );
   snd_arch_p      :=loadSND('d_arch_p.wav' );
   snd_arch_c      :=loadSND('d_arch_c.wav' );
   snd_arch_f      :=loadSND('d_arch_f.wav' );
   snd_demonc      :=loadSND('d_u2.wav'     );
   snd_demona      :=loadSND('d_u2_a.wav'   );
   snd_demond      :=loadSND('d_u2_d.wav'   );
   snd_hmelee      :=loadSND('d_melee.wav'  );
   snd_demon1      :=loadSND('d_0.wav'      );
   snd_imp         :=loadSND('d_imp.wav'    );
   snd_impd1       :=loadSND('d_u1_d1.wav'  );
   snd_impd2       :=loadSND('d_u1_d2.wav'  );
   snd_impc1       :=loadSND('d_u1_s1.wav'  );
   snd_impc2       :=loadSND('d_u1_s2.wav'  );
   snd_dpain       :=loadSND('d_p.wav'      );
   snd_cacoc       :=loadSND('d_u3.wav'     );
   snd_cacod       :=loadSND('d_u3_d.wav'   );
   snd_baronc      :=loadSND('d_u4.wav'     );
   snd_barond      :=loadSND('d_u4_d.wav'   );
   snd_knight      :=loadSND('knight.wav'   );
   snd_knightd     :=loadSND('knightd.wav'  );
   snd_cyberc      :=loadSND('d_u5.wav'     );
   snd_cyberd      :=loadSND('d_u5_d.wav'   );
   snd_cyberf      :=loadSND('d_u5_f.wav'   );
   snd_mindc       :=loadSND('d_u6.wav'     );
   snd_mindd       :=loadSND('d_u6_d.wav'   );
   snd_mindf       :=loadSND('d_u6_f.wav'   );
   snd_pain_c      :=loadSND('d_pain_c.wav' );
   snd_pain_p      :=loadSND('d_pain_p.wav' );
   snd_pain_d      :=loadSND('d_pain_d.wav' );
   snd_uac_u0      :=loadSND('uac_u0.wav');
   snd_uac_u1      :=loadSND('uac_u1.wav');
   snd_uac_u2      :=loadSND('uac_u2.wav');
   snd_z_s1        :=loadSND('d_z_s1.wav');
   snd_z_s2        :=loadSND('d_z_s2.wav');
   snd_z_s3        :=loadSND('d_z_s3.wav');
   snd_z_d1        :=loadSND('d_z_d1.wav');
   snd_z_d2        :=loadSND('d_z_d2.wav');
   snd_z_d3        :=loadSND('d_z_d3.wav');
   snd_z_p         :=loadSND('d_z_p.wav');
   snd_ud1         :=loadSND('h_d1.wav');
   snd_ud2         :=loadSND('h_d2.wav');
   snd_zomb        :=loadSND('d_z_ac.wav');
   snd_man_a       :=loadSND('d_man_a.wav');
   snd_man_d       :=loadSND('d_man_d.wav');
   snd_man_p       :=loadSND('d_man_p.wav');
   snd_man_c       :=loadSND('d_man_c.wav');
   snd_hshoot      :=loadSND('d_a.wav');
   snd_rev_c       :=loadSND('d_rev_c.wav');
   snd_rev_m       :=loadSND('d_rev_m.wav');
   snd_rev_d       :=loadSND('d_rev_d.wav');
   snd_rev_a       :=loadSND('d_rev_a.wav');
   snd_rev_ac      :=loadSND('d_rev_ac.wav');
   snd_cubes       :=loadSND('cube_s.wav');
   snd_launch      :=loadSND('launch.wav');
   snd_pistol      :=loadSND('h_u0_a.WAV');
   snd_shotgun     :=loadSND('h_u1_a.wav');
   snd_rico        :=loadSND('rico1.wav');
   snd_ssg         :=loadSND('ssg.wav');
   snd_bfgs        :=loadSND('h_u5_a.wav');
   snd_bfgepx      :=loadSND('bfg_exp.wav');
   snd_plasmas     :=loadSND('h_u4_a.wav');
   snd_cast2       :=loadSND('rep.wav');
   snd_cast        :=loadSND('h_u0_r.wav');
   snd_uupgr       :=loadSND('uup.wav');
   snd_hupgr       :=loadSND('hup.wav');
   snd_alarm       :=loadSND('alarm.wav');
   snd_hellbar     :=loadSND('hellbarracks.wav');
   snd_hell        :=loadSND('hell.wav'     );
   snd_hpower      :=loadSND('hpower.wav');
   snd_fly_a1      :=loadSND('flyer_a1.wav');
   snd_fly_a       :=loadSND('flyer_a.wav');
   snd_jetpoff     :=loadSND('jetpoff.wav');
   snd_jetpon      :=loadSND('jetpon.wav');
   snd_oof         :=loadSND('oof.wav');    }

   InitSound:=true;
end;




