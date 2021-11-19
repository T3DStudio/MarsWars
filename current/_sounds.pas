

function load_music(fn:string):pMIX_MUSIC;
begin
   fn:=str_f_msc+fn+#0;
   load_music:=MIX_LOADMUS(@fn[1]);
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

function Load_Chunk(fn:shortstring):pMIX_Chunk;
var n:shortstring;
begin
   n:=str_f_snd+fn+'.wav'+#0;
   Load_Chunk:=mix_loadwav(@n[1]);
end;

function load_sound(fn:shortstring):PTMWSound;
var t:pMIX_Chunk;
begin
   load_sound:=nil;
   t := Load_Chunk(fn);
   if(t<>nil)then
   begin
      new(load_sound);
      with load_sound^ do
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
      sndn+=1;
      setlength(snds,sndn);
      snds[sndn-1]:=tsnd;
   end;
end;

function Load_SoundSet(fname:shortstring):PTSoundSet;
var tsnd:PTMWSound;
       i:integer;
begin
   i:=0;
   new(Load_SoundSet);
   with Load_SoundSet^ do
   begin
      sndps:=0;
      sndn :=0;
      setlength(snds,sndn);

      tsnd:=load_sound(fname);
      if(tsnd<>nil)then AddToSoundSet(Load_SoundSet,tsnd);

      while true do
      begin
         tsnd:=load_sound(fname+i2s(i));
         if(tsnd=nil)then
          if(i=0)then
          begin
             i+=1;
             continue;
          end
          else break;

         AddToSoundSet(Load_SoundSet,tsnd);
         i+=1;
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
          snd_current_music+=1;
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
        sndps+=1;
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
   or(r_draw=false)then exit;

   if(visdata<>nil)then
   begin
      if(visdata^=false)then exit;
   end
   else
     if(pu<>nil)then
      with pu^ do
       if(PointInScreenF(x,y,player)=false)then exit;

   PlaySoundSet(ss,nil);
   PlaySND:=true;
end;

procedure PlaySNDM(ss:PTSoundSet);
begin
   if(ss=nil)
   or(r_draw=false)then exit;

   PlaySoundSet(ss,nil);
end;

procedure PlayInGameAnoncer(ss:PTSoundSet);
const min_snd_pause = fr_4hfps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(r_draw=false)then exit;

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
const min_snd_pause = fr_2hfps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(r_draw=false)then exit;

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
        then ui_UnitSelectedn+=1
        else ui_UnitSelectedn:=0;

      with _units[ui_UnitSelectedNU] do
      with uid^ do
       if(_ukbuilding)and(bld=false)
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
         snd_music_list[snd_music_list_size]:=load_music(s);
         snd_music_list_size+=1;
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

procedure SoundControl;
begin
   if(vid_rtui=0)then _MusicCheck;
   if(snd_anoncer_pause>0)then snd_anoncer_pause-=1;
   if(snd_unitcmd_pause>0)then snd_unitcmd_pause-=1;
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

   snd_click                :=Load_SoundSet('click'           );
   snd_chat                 :=Load_SoundSet('chat'            );
   snd_building_explode     :=Load_SoundSet('building_explode');
   snd_teleport             :=Load_SoundSet('teleport'        );
   snd_exp                  :=Load_SoundSet('explode'         );
   snd_mine_place           :=Load_SoundSet('mine_place'      );
   snd_inapc                :=Load_SoundSet('inapc'           );
   snd_meat                 :=Load_SoundSet('meat'            );

   snd_pexp                 :=Load_SoundSet(missiles_folder+'p_exp'           );
   snd_launch               :=Load_SoundSet(missiles_folder+'launch'          );
   snd_pistol               :=Load_SoundSet(missiles_folder+'pistol'          );
   snd_shotgun              :=Load_SoundSet(missiles_folder+'shotgun'         );
   snd_ssg                  :=Load_SoundSet(missiles_folder+'ssg'             );
   snd_plasma               :=Load_SoundSet(missiles_folder+'plasma'          );
   snd_bfg_shot             :=Load_SoundSet(missiles_folder+'bfg_shot'        );
   snd_healing              :=Load_SoundSet(missiles_folder+'healing'         );
   snd_electro              :=Load_SoundSet(missiles_folder+'electro'         );
   snd_rico                 :=Load_SoundSet(missiles_folder+'rico'            );
   snd_bfg_exp              :=Load_SoundSet(missiles_folder+'bfg_exp'         );
   snd_flyer_s              :=Load_SoundSet(missiles_folder+'flyer_s'         );
   snd_flyer_a              :=Load_SoundSet(missiles_folder+'flyer_a'         );

   for r:=1 to r_cnt do
   begin
   snd_under_attack[true ,r]:=Load_SoundSet(race_dir[r]+'base_under_attack'         );
   snd_under_attack[false,r]:=Load_SoundSet(race_dir[r]+'unit_under_attack'         );
   snd_build_place       [r]:=Load_SoundSet(race_dir[r]+'build_place'               );
   snd_building          [r]:=Load_SoundSet(race_dir[r]+'building'                  );
   snd_constr_complete   [r]:=Load_SoundSet(race_dir[r]+'construction_complete'     );
   snd_cannot_build      [r]:=Load_SoundSet(race_dir[r]+'cannot_build_here'         );
   snd_defeat            [r]:=Load_SoundSet(race_dir[r]+'defeat'                    );
   snd_not_enough_energy [r]:=Load_SoundSet(race_dir[r]+'not_enough_energy'         );
   snd_player_defeated   [r]:=Load_SoundSet(race_dir[r]+'player_defeated'           );
   snd_upgrade_complete  [r]:=Load_SoundSet(race_dir[r]+'upgrade_complete'          );
   snd_victory           [r]:=Load_SoundSet(race_dir[r]+'victory'                   );
   snd_unit_adv          [r]:=Load_SoundSet(race_dir[r]+'unit_adv'                  );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_radar                :=Load_SoundSet(race_dir[r_uac]+'radar');

   snd_jetpoff              :=Load_SoundSet(race_dir[r_uac]+'jetpoff');
   snd_jetpon               :=Load_SoundSet(race_dir[r_uac]+'jetpon' );
   snd_CCup                 :=Load_SoundSet(race_dir[r_uac]+'ccup'   );

   snd_uac_cc               :=Load_SoundSet(race_buildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=Load_SoundSet(race_buildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=Load_SoundSet(race_buildings[r_uac ]+'generator'      );
   snd_uac_smith            :=Load_SoundSet(race_buildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=Load_SoundSet(race_buildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=Load_SoundSet(race_buildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=Load_SoundSet(race_buildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=Load_SoundSet(race_buildings[r_uac ]+'factory'        );
   snd_uac_tech             :=Load_SoundSet(race_buildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=Load_SoundSet(race_buildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=Load_SoundSet(race_buildings[r_uac ]+'nuclear_plant'  );

   snd_uac_suply            :=Load_SoundSet(race_buildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=Load_SoundSet(race_buildings[r_uac ]+'resourse_senter');

   snd_uac_hdeath           :=Load_SoundSet(race_units[r_uac ]+'death'              );

   snd_APC_ready            :=Load_SoundSet(race_units[r_uac ]+'APC\UAC_im_find2'   );
   snd_APC_move             :=Load_SoundSet(race_units[r_uac ]+'APC\uac_u'          );

   snd_bfgmarine_ready      :=Load_SoundSet(race_units[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=Load_SoundSet(race_units[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=Load_SoundSet(race_units[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=Load_SoundSet(race_units[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=Load_SoundSet(race_units[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=Load_SoundSet(race_units[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=Load_SoundSet(race_units[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=Load_SoundSet(race_units[r_uac ]+'commando\attack'    );
   snd_commando_select      :=Load_SoundSet(race_units[r_uac ]+'commando\select'    );
   snd_commando_move        :=Load_SoundSet(race_units[r_uac ]+'commando\move'      );

   snd_engineer_ready       :=Load_SoundSet(race_units[r_uac ]+'engineer\ready'     );
   snd_engineer_annoy       :=Load_SoundSet(race_units[r_uac ]+'engineer\annoy'     );
   snd_engineer_attack      :=Load_SoundSet(race_units[r_uac ]+'engineer\attack'    );
   snd_engineer_select      :=Load_SoundSet(race_units[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=Load_SoundSet(race_units[r_uac ]+'engineer\move'      );

   snd_medic_ready          :=Load_SoundSet(race_units[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=Load_SoundSet(race_units[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=Load_SoundSet(race_units[r_uac ]+'medic\select'       );
   snd_medic_move           :=Load_SoundSet(race_units[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=Load_SoundSet(race_units[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=Load_SoundSet(race_units[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=Load_SoundSet(race_units[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=Load_SoundSet(race_units[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=Load_SoundSet(race_units[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=Load_SoundSet(race_units[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=Load_SoundSet(race_units[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=Load_SoundSet(race_units[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=Load_SoundSet(race_units[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=Load_SoundSet(race_units[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=Load_SoundSet(race_units[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=Load_SoundSet(race_units[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=Load_SoundSet(race_units[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=Load_SoundSet(race_units[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=Load_SoundSet(race_units[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=Load_SoundSet(race_units[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=Load_SoundSet(race_units[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=Load_SoundSet(race_units[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=Load_SoundSet(race_units[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=Load_SoundSet(race_units[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=Load_SoundSet(race_units[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=Load_SoundSet(race_units[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=Load_SoundSet(race_units[r_uac ]+'tank\attack'        );
   snd_tank_select          :=Load_SoundSet(race_units[r_uac ]+'tank\select'        );
   snd_tank_move            :=Load_SoundSet(race_units[r_uac ]+'tank\move'          );

   snd_terminator_ready     :=Load_SoundSet(race_units[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=Load_SoundSet(race_units[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=Load_SoundSet(race_units[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=Load_SoundSet(race_units[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=Load_SoundSet(race_units[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=Load_SoundSet(race_units[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=Load_SoundSet(race_units[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=Load_SoundSet(race_units[r_uac ]+'transport\select'   );
   snd_transport_move       :=Load_SoundSet(race_units[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=Load_SoundSet(race_units[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=Load_SoundSet(race_units[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=Load_SoundSet(race_units[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=Load_SoundSet(race_units[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=Load_SoundSet(race_units[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=Load_SoundSet(race_buildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=Load_SoundSet(race_buildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=Load_SoundSet(race_buildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=Load_SoundSet(race_buildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=Load_SoundSet(race_buildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=Load_SoundSet(race_buildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=Load_SoundSet(race_buildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=Load_SoundSet(race_buildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=Load_SoundSet(race_buildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=Load_SoundSet(race_buildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=Load_SoundSet(race_buildings[r_hell]+'hell_building' );
   snd_hell_eye             :=Load_SoundSet(race_buildings[r_hell]+'hell_eye'      );



   snd_hell_invuln          :=Load_SoundSet(race_units[r_hell]+'invuln');
   snd_hell_pain            :=Load_SoundSet(race_units[r_hell]+'d_p');
   snd_hell_melee           :=Load_SoundSet(race_units[r_hell]+'d_m');
   snd_hell_attack          :=Load_SoundSet(race_units[r_hell]+'d_a');
   snd_hell_move            :=Load_SoundSet(race_units[r_hell]+'d_' );

   snd_zimba_death          :=Load_SoundSet(race_units[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=Load_SoundSet(race_units[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=Load_SoundSet(race_units[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=Load_SoundSet(race_units[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=Load_SoundSet(race_units[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=Load_SoundSet(race_units[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=Load_SoundSet(race_units[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=Load_SoundSet(race_units[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=Load_SoundSet(race_units[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=Load_SoundSet(race_units[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=Load_SoundSet(race_units[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=Load_SoundSet(race_units[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=Load_SoundSet(race_units[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=Load_SoundSet(race_units[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=Load_SoundSet(race_units[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=Load_SoundSet(race_units[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=Load_SoundSet(race_units[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=Load_SoundSet(race_units[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=Load_SoundSet(race_units[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=Load_SoundSet(race_units[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=Load_SoundSet(race_units[r_hell]+'knight\knightc');
   snd_knight_death         :=Load_SoundSet(race_units[r_hell]+'knight\knightd');
   snd_baron_ready          :=Load_SoundSet(race_units[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=Load_SoundSet(race_units[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=Load_SoundSet(race_units[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=Load_SoundSet(race_units[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=Load_SoundSet(race_units[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=Load_SoundSet(race_units[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=Load_SoundSet(race_units[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=Load_SoundSet(race_units[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=Load_SoundSet(race_units[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=Load_SoundSet(race_units[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=Load_SoundSet(race_units[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=Load_SoundSet(race_units[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=Load_SoundSet(race_units[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=Load_SoundSet(race_units[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=Load_SoundSet(race_units[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=Load_SoundSet(race_units[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=Load_SoundSet(race_units[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=Load_SoundSet(race_units[r_hell]+'arachnotron\d_ar_c');


  {snd_inapc       :=load_sound('inapc.wav'    );
   snd_ccup        :=load_sound('ccup.wav'     );

   snd_meat        :=load_sound('gv.wav'       );
   snd_d0          :=load_sound('d_u0.wav'     );
   snd_ar_act      :=load_sound('d_ar_act.wav' );
   snd_ar_d        :=load_sound('d_ar_d.wav'   );
   snd_ar_c        :=load_sound('d_ar_c.wav'   );
   snd_ar_f        :=load_sound('d_ar_f.wav'   );
   snd_arch_a      :=load_sound('d_arch_a.wav' );
   snd_arch_at     :=load_sound('d_arch_at.wav');
   snd_arch_d      :=load_sound('d_arch_d.wav' );
   snd_arch_p      :=load_sound('d_arch_p.wav' );
   snd_arch_c      :=load_sound('d_arch_c.wav' );
   snd_arch_f      :=load_sound('d_arch_f.wav' );
   snd_demonc      :=load_sound('d_u2.wav'     );
   snd_demona      :=load_sound('d_u2_a.wav'   );
   snd_demond      :=load_sound('d_u2_d.wav'   );
   snd_hmelee      :=load_sound('d_melee.wav'  );
   snd_demon1      :=load_sound('d_0.wav'      );
   snd_imp         :=load_sound('d_imp.wav'    );
   snd_impd1       :=load_sound('d_u1_d1.wav'  );
   snd_impd2       :=load_sound('d_u1_d2.wav'  );
   snd_impc1       :=load_sound('d_u1_s1.wav'  );
   snd_impc2       :=load_sound('d_u1_s2.wav'  );
   snd_dpain       :=load_sound('d_p.wav'      );
   snd_cacoc       :=load_sound('d_u3.wav'     );
   snd_cacod       :=load_sound('d_u3_d.wav'   );
   snd_baronc      :=load_sound('d_u4.wav'     );
   snd_barond      :=load_sound('d_u4_d.wav'   );
   snd_knight      :=load_sound('knight.wav'   );
   snd_knightd     :=load_sound('knightd.wav'  );
   snd_cyberc      :=load_sound('d_u5.wav'     );
   snd_cyberd      :=load_sound('d_u5_d.wav'   );
   snd_cyberf      :=load_sound('d_u5_f.wav'   );
   snd_mindc       :=load_sound('d_u6.wav'     );
   snd_mindd       :=load_sound('d_u6_d.wav'   );
   snd_mindf       :=load_sound('d_u6_f.wav'   );
   snd_pain_c      :=load_sound('d_pain_c.wav' );
   snd_pain_p      :=load_sound('d_pain_p.wav' );
   snd_pain_d      :=load_sound('d_pain_d.wav' );
   snd_uac_u0      :=load_sound('uac_u0.wav');
   snd_uac_u1      :=load_sound('uac_u1.wav');
   snd_uac_u2      :=load_sound('uac_u2.wav');
   snd_z_s1        :=load_sound('d_z_s1.wav');
   snd_z_s2        :=load_sound('d_z_s2.wav');
   snd_z_s3        :=load_sound('d_z_s3.wav');
   snd_z_d1        :=load_sound('d_z_d1.wav');
   snd_z_d2        :=load_sound('d_z_d2.wav');
   snd_z_d3        :=load_sound('d_z_d3.wav');
   snd_z_p         :=load_sound('d_z_p.wav');
   snd_ud1         :=load_sound('h_d1.wav');
   snd_ud2         :=load_sound('h_d2.wav');
   snd_zomb        :=load_sound('d_z_ac.wav');
   snd_man_a       :=load_sound('d_man_a.wav');
   snd_man_d       :=load_sound('d_man_d.wav');
   snd_man_p       :=load_sound('d_man_p.wav');
   snd_man_c       :=load_sound('d_man_c.wav');
   snd_hshoot      :=load_sound('d_a.wav');
   snd_rev_c       :=load_sound('d_rev_c.wav');
   snd_rev_m       :=load_sound('d_rev_m.wav');
   snd_rev_d       :=load_sound('d_rev_d.wav');
   snd_rev_a       :=load_sound('d_rev_a.wav');
   snd_rev_ac      :=load_sound('d_rev_ac.wav');
   snd_cubes       :=load_sound('cube_s.wav');
   snd_launch      :=load_sound('launch.wav');
   snd_pistol      :=load_sound('h_u0_a.WAV');
   snd_shotgun     :=load_sound('h_u1_a.wav');
   snd_rico        :=load_sound('rico1.wav');
   snd_ssg         :=load_sound('ssg.wav');
   snd_bfgs        :=load_sound('h_u5_a.wav');
   snd_bfgepx      :=load_sound('bfg_exp.wav');
   snd_plasmas     :=load_sound('h_u4_a.wav');
   snd_cast2       :=load_sound('rep.wav');
   snd_cast        :=load_sound('h_u0_r.wav');
   snd_uupgr       :=load_sound('uup.wav');
   snd_hupgr       :=load_sound('hup.wav');
   snd_alarm       :=load_sound('alarm.wav');
   snd_hellbar     :=load_sound('hellbarracks.wav');
   snd_hell        :=load_sound('hell.wav'     );
   snd_hpower      :=load_sound('hpower.wav');
   snd_fly_a1      :=load_sound('flyer_a1.wav');
   snd_fly_a       :=load_sound('flyer_a.wav');
   snd_jetpoff     :=load_sound('jetpoff.wav');
   snd_jetpon      :=load_sound('jetpon.wav');
   snd_oof         :=load_sound('oof.wav');    }

   InitSound:=true;
end;




