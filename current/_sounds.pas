
////////////////////////////////////////////////////////////////////////////////
//
//   LOAD
//




function oalError:boolean;begin oalError:=alGetError()<>AL_NO_ERROR;end;

function Load_Chunk(fname:shortstring):TALuint;
var str,stre : shortstring;
SLformat: TALenum = 0;
SLdata  : TALvoid = nil;
SLsize  : TALsizei= 0;
SLfreq  : TALsizei= 0;
SLloop  : TALint  = 0;

procedure load_wav(sfn:shortstring);
begin
   oalError();

   alGenBuffers   (1,    @Load_Chunk);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alutLoadWAVFile(sfn   ,SLformat,SLdata,SLsize,SLfreq,SLloop);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alBufferData   (Load_Chunk,SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then begin Load_Chunk:=0;exit;end;
   alutUnloadWAV  (       SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then Load_Chunk:=0;
end;

procedure load_ogg(sfn:shortstring);
var
SLformat: TALenum     = 0;
SLdata  : TALvoid     = nil;
SLsize  : TALsizei    = 0;
SLfreq  : TALsizei    = 0;
error   : shortstring = '';
begin
   oalError();

   alGenBuffers(1,@Load_Chunk);
   if(oalError)then begin Load_Chunk:=0;exit;end;

   if(LoadOGGData(sfn,@SLformat,@SLdata,@SLsize,@SLfreq,@error))then
   begin
      alBufferData(Load_Chunk,SLformat,SLdata,SLsize,SLfreq);
      if(oalError)then Load_Chunk:=0;
      FreeOGGData(@SLdata,@SLsize);
   end
   else
   begin
      WriteLog(sfn+' '+error);
      alDeleteBuffers(1,@Load_Chunk);
      Load_Chunk:=0;
   end;
end;

begin
   Load_Chunk:=0;
   str:=str_f_snd+fname;

   stre:=str+'.wav';
   if FileExists(stre)then
   begin
      load_wav(stre);
      if(Load_Chunk=0)then WriteLog(stre+' error!');
      exit;
   end;

   stre:=str+'.ogg';
   if FileExists(stre)then
   begin
      load_ogg(stre);
      if(Load_Chunk=0)then WriteLog(stre+' error!');
      exit;
   end;
end;


function load_sound(fn:shortstring):PTMWSound;
var t:TALuint;
begin
   load_sound:=nil;
   t := Load_Chunk(fn);
   if(t<>0)then
   begin
      new(load_sound);
      load_sound^.sound:=t;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SoundSets
//

procedure SoundSetAdd(ss:PTSoundSet;tsnd:PTMWSound);
begin
   if(tsnd<>nil)then
   with ss^ do
   begin
      sndn+=1;
      setlength(snds,sndn);
      snds[sndn-1]:=tsnd;
   end;
end;

function SoundSetLoad(fname:shortstring):PTSoundSet;
var tsnd:PTMWSound;
       i:integer;
begin
   i:=0;
   new(SoundSetLoad);
   with SoundSetLoad^ do
   begin
      sndps:=0;
      sndn :=0;
      setlength(snds,sndn);

      tsnd:=load_sound(fname);
      if(tsnd<>nil)then SoundSetAdd(SoundSetLoad,tsnd);

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

         SoundSetAdd(SoundSetLoad,tsnd);
         i+=1;
      end;
      if(sndn<=0)then WriteLog(fname);
   end;
end;

procedure SoundShafleSoundSet(SoundSet:PTSoundSet);
var i,
m1,m2 : integer;
  snd : PTMWSound;
begin
   with SoundSet^ do
    if(sndn>1)then
     for i:=0 to sndn+5 do
     begin
        m1:=random(sndn);
        m2:=random(sndn);

        snd:=snds[m1];
        snds[m1]:=snds[m2];
        snds[m2]:=snd;
        sndps:=random(sndn);
     end;
end;

function SoundSetGetChunk(ss:PTSoundSet):PTMWSound;
begin
   SoundSetGetChunk:=nil;
   with ss^ do
    if(sndn>0)then
     if(sndn=1)
     then SoundSetGetChunk:=snds[0]
     else
     begin
        sndps+=1;
        if(sndps<0)or(sndps>=sndn)then sndps:=0;
        SoundSetGetChunk:=snds[sndps];
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SOURCE SETs
//

procedure SoundSourceSetInit(sss:PTMWSoundSourceSet;sssn:integer;avolumevar:psingle);
begin
   if(sssn>0)then
   with sss^ do
   begin
      setlength(ssl,sssn);
      ssn:=sssn;

      while(sssn>0)do
      begin
         sssn-=1;
         with ssl[sssn] do
         begin
            alGenSources(1,@source);
            alSourcefv(source, AL_POSITION, @SLpos);
            volumevar:=avolumevar;
         end;
      end;
   end;
end;

procedure SoundSourceUpdateGain(SoundSourceSet:PTMWSoundSourceSet);
var i:integer;
begin
   with SoundSourceSet^ do
    if(ssn>0)then
     for i:=0 to ssn-1 do
      with ssl[i] do
       if(volumevar<>nil)then alSourcef(source,AL_GAIN,volumevar^);
end;
procedure SoundSourceUpdateGainAll;
var s:integer;
begin
   for s:=0 to sss_count-1 do SoundSourceUpdateGain(@SoundSources[s]);
end;

function SourceIsPlaying(source:TALuint):boolean;
var i:TALint;
begin
   alGetSourcei(source,AL_SOURCE_STATE,@i);
   SourceisPlaying:=(i=AL_PLAYING);
end;
function SoundSourceSetIsPlaying(SoundSourceSet:PTMWSoundSourceSet):boolean;
var i:integer;
begin
   SoundSourceSetIsPlaying:=false;

   with SoundSourceSet^ do
    if(ssn>0)then
     for i:=0 to ssn-1 do
      with ssl[i] do
       if(SourceIsPlaying(source))then
       begin
          SoundSourceSetIsPlaying:=true;
          break;
       end;
end;

function SoundSourceSetGetSource(SoundSourceSet:PTMWSoundSourceSet):PTMWSoundSource;
var i:integer;
begin
   SoundSourceSetGetSource:=nil;

   with SoundSourceSet^ do
    if(ssn>0)then
     if(ssn=1)
     then SoundSourceSetGetSource:=@ssl[0]
     else
      for i:=0 to ssn-1 do
       with ssl[i] do
        if(SourceIsPlaying(source)=false)then SoundSourceSetGetSource:=@ssl[i];
end;


////////////////////////////////////////////////////////////////////////////////
//
//   PLAY
//


procedure SoundPlay(SoundSet:PTSoundSet;sss:byte);
var vsound :PTMWSound;
    vsource:PTMWSoundSource;
begin
   if(sss>=sss_count)then exit;

   vsound :=SoundSetGetChunk(SoundSet);
   vsource:=SoundSourceSetGetSource(@SoundSources[sss]);

   if(vsound<>nil)and(vsource<>nil)then
   with vsound^  do
   with vsource^ do
   begin
      alSourceStop(source);

      if(volumevar<>nil)then
      alSourcef   (source, AL_GAIN  , volumevar^);

      alSourcei   (source, AL_BUFFER, sound  );
      alSourcePlay(source);
   end;
end;

function SoundPlayUnit(ss:PTSoundSet;pu:PTUnit;visdata:pboolean):boolean;
begin
   SoundPlayUnit:=false;
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
       if(PointInScreenP(x,y,player)=false)then exit;

   SoundPlay(ss,sss_world);
   SoundPlayUnit:=true;
end;

procedure SoundPlayUI(ss:PTSoundSet);
begin
   if(ss=nil)
   or(r_draw=false)then exit;

   SoundPlay(ss,sss_ui);
end;

procedure SoundPlayAnoncer(ss:PTSoundSet;pause:boolean);
begin
   if(ss=nil)
   or(_menu)
   or(r_draw=false)then exit;

   if(pause)and(snd_anoncer_last=ss)and(snd_anoncer_ticks>0)then exit;

   SoundPlay(ss,sss_anoncer);

   snd_anoncer_ticks:=fr_fps1;
   snd_anoncer_last :=ss;
end;
procedure SoundPlayMMapAlarm(ss:PTSoundSet;pause:boolean);
begin
   if(ss=nil)
   or(_menu)
   or(r_draw=false)then exit;

   if(pause)and(snd_mmap_last=ss)and(snd_mmap_ticks>0)then exit;

   SoundPlay(ss,sss_mmap);

   snd_mmap_ticks:=fr_fps1;
   snd_mmap_last :=ss;
end;

procedure SoundPlayUnitCommand(ss:PTSoundSet);
begin
   if(ss=nil)
   or(_menu)
   or(r_draw=false)then exit;

   if(snd_command_last=ss)and(snd_command_ticks>0)then exit;

   SoundPlay(ss,sss_ucommand);

   snd_command_last:=ss;
   snd_command_ticks:=fr_fps2d3;
end;

procedure SoundPlayUnitSelect;
const annoystart = 6;
      annoystop  = 12;
begin
   if(_IsUnitRange(ui_UnitSelectedNU,nil))then
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
        then SoundPlayUnitCommand(snd_building[_urace])
        else
         if(ui_UnitSelectedn<annoystart)
         then SoundPlayUnitCommand(un_snd_select)
         else SoundPlayUnitCommand(un_snd_annoy );

      ui_UnitSelectedPU:=ui_UnitSelectedNU;
      ui_UnitSelectedNU:=0;
   end;
end;

procedure SoundLogHPlayer;
begin
   with _players[HPlayer] do
    with log_l[log_i] do
     case mtype of
0..MaxPlayers         : if(mtype<>HPlayer)
                        or((rpls_state>=rpl_rhead)and(HPlayer=0))then SoundPlayUI(snd_chat);
lmt_player_chat,
lmt_game_message      : SoundPlayUI(snd_chat);
lmt_game_end          : if(argx<=MaxPlayers)then
                         if(argx=team)
                         then SoundPlayAnoncer(snd_victory[race],false)
                         else SoundPlayAnoncer(snd_defeat [race],false);
lmt_player_defeated   : if(argx<=MaxPlayers)
                        then SoundPlayAnoncer(snd_player_defeated[race],true);
lmt_cant_build        : SoundPlayAnoncer(snd_cannot_build [race],true);
lmt_unit_advanced     : SoundPlayAnoncer(snd_unit_promoted[race],true);
lmt_upgrade_complete  : SoundPlayAnoncer(snd_upgrade_complete[race],true);
lmt_unit_ready        : with _uids[argx] do
                        SoundPlayUnitCommand(un_snd_ready);
lmt_req_energy        : SoundPlayAnoncer(snd_not_enough_energy[race],true);
lmt_already_adv,
lmt_NeedMoreProd,
lmt_unit_limit,
lmt_production_busy,
lmt_req_ruids,
lmt_req_common,
lmt_cant_order        : SoundPlayAnoncer(snd_cant_order[race],true);
lmt_map_mark          : SoundPlayAnoncer(snd_mapmark,false);
lmt_allies_attacked   : SoundPlayAnoncer(snd_mapmark,false);
lmt_unit_attacked     : with _uids[argx] do
                        SoundPlayMMapAlarm(snd_under_attack[_ukbuilding,race],true);
     end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MUSIC
//

procedure SoundMusicControll;
var current_music_ss: PTSoundSet;
begin
   if(G_Started)
   then current_music_ss:=snd_music_game
   else current_music_ss:=snd_music_menu;

   if(snd_music_current<>current_music_ss)or(SoundSourceSetIsPlaying(@SoundSources[sss_music])=false)then
   begin
      snd_music_current:=current_music_ss;

      SoundPlay(snd_music_current,sss_music);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MAIN
//

procedure SoundControl;
begin
   if(vid_blink_timer1=0)then SoundMusicControll;
   if(snd_anoncer_ticks>0)then snd_anoncer_ticks-=1;
   if(snd_command_ticks>0)then snd_command_ticks-=1;

   if(G_Started)and(G_status=0)and(not _menu)
   then SoundPlayUnitSelect;
end;


function InitSound:boolean;
var r:integer;
begin
   InitSound:=false;

   if(InitOpenAL=false)then exit;

   if(oalError)then exit;

   MainDevice  := alcOpenDevice(nil);
   MainContext := alcCreateContext(MainDevice,nil);
   alcMakeContextCurrent(MainContext);

   if(oalError)then exit;

   FillChar(SLpos,SizeOf(SLpos),0);
   FillChar(SLori,SizeOf(SLori),0);

   alListenerfv(AL_POSITION   ,@SLPos);
   alListenerfv(AL_ORIENTATION,@SLOri);

   for r:=0 to sss_count-1 do
    case r of
    sss_music: SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_mvolume1);
    else       SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_svolume1);
    end;

   snd_music_menu:=SoundSetLoad('music\mm');
   snd_music_game:=SoundSetLoad('music\m');

   SoundShafleSoundSet(@snd_music_menu);
   SoundShafleSoundSet(@snd_music_game);
   /////////////////////////////////////////////////////////////////////////////////
   //
   // COMMON
   //

   snd_click                :=SoundSetLoad('click'           );
   snd_chat                 :=SoundSetLoad('chat'            );
   snd_building_explode     :=SoundSetLoad('building_explode');
   snd_teleport             :=SoundSetLoad('teleport'        );
   snd_exp                  :=SoundSetLoad('explode'         );
   snd_mine_place           :=SoundSetLoad('mine_place'      );
   snd_transport                :=SoundSetLoad('inapc'           );
   snd_meat                 :=SoundSetLoad('meat'            );
   snd_cube                 :=SoundSetLoad('cube_s'          );
   snd_hpower               :=SoundSetLoad('hpower'          );
   snd_mapmark              :=SoundSetLoad('mapmark'         );

   snd_pexp                 :=SoundSetLoad(missiles_folder+'p_exp'           );
   snd_launch               :=SoundSetLoad(missiles_folder+'launch'          );
   snd_pistol               :=SoundSetLoad(missiles_folder+'pistol'          );
   snd_shotgun              :=SoundSetLoad(missiles_folder+'shotgun'         );
   snd_ssg                  :=SoundSetLoad(missiles_folder+'ssg'             );
   snd_plasma               :=SoundSetLoad(missiles_folder+'plasma'          );
   snd_bfg_shot             :=SoundSetLoad(missiles_folder+'bfg_shot'        );
   snd_healing              :=SoundSetLoad(missiles_folder+'healing'         );
   snd_electro              :=SoundSetLoad(missiles_folder+'electro'         );
   snd_rico                 :=SoundSetLoad(missiles_folder+'rico'            );
   snd_bfg_exp              :=SoundSetLoad(missiles_folder+'bfg_exp'         );
   snd_flyer_s              :=SoundSetLoad(missiles_folder+'flyer_s'         );
   snd_flyer_a              :=SoundSetLoad(missiles_folder+'flyer_a'         );

   for r:=1 to r_cnt do
   begin
   snd_under_attack[true ,r]:=SoundSetLoad(race_dir[r]+'base_under_attack'         );
   snd_under_attack[false,r]:=SoundSetLoad(race_dir[r]+'unit_under_attack'         );
   snd_build_place       [r]:=SoundSetLoad(race_dir[r]+'build_place'               );
   snd_building          [r]:=SoundSetLoad(race_dir[r]+'building'                  );
   snd_constr_complete   [r]:=SoundSetLoad(race_dir[r]+'construction_complete'     );
   snd_cannot_build      [r]:=SoundSetLoad(race_dir[r]+'cannot_build_here'         );
   snd_defeat            [r]:=SoundSetLoad(race_dir[r]+'defeat'                    );
   snd_not_enough_energy [r]:=SoundSetLoad(race_dir[r]+'not_enough_energy'         );
   snd_player_defeated   [r]:=SoundSetLoad(race_dir[r]+'player_defeated'           );
   snd_upgrade_complete  [r]:=SoundSetLoad(race_dir[r]+'upgrade_complete'          );
   snd_victory           [r]:=SoundSetLoad(race_dir[r]+'victory'                   );
   snd_unit_adv          [r]:=SoundSetLoad(race_dir[r]+'unit_adv'                  );
   snd_unit_promoted     [r]:=SoundSetLoad(race_dir[r]+'unit_promoted'             );
   snd_cant_order        [r]:=SoundSetLoad(race_dir[r]+'cant_order'                );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_radar                :=SoundSetLoad(race_dir[r_uac]+'radar');

   snd_jetpoff              :=SoundSetLoad(race_dir[r_uac]+'jetpoff'   );
   snd_jetpon               :=SoundSetLoad(race_dir[r_uac]+'jetpon'    );
   snd_CCup                 :=SoundSetLoad(race_dir[r_uac]+'ccup'      );
   snd_bomblaunch           :=SoundSetLoad(race_dir[r_uac]+'bomblaunch');

   snd_uac_cc               :=SoundSetLoad(race_buildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=SoundSetLoad(race_buildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=SoundSetLoad(race_buildings[r_uac ]+'generator'      );
   snd_uac_smith            :=SoundSetLoad(race_buildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=SoundSetLoad(race_buildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=SoundSetLoad(race_buildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=SoundSetLoad(race_buildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=SoundSetLoad(race_buildings[r_uac ]+'factory'        );
   snd_uac_tech             :=SoundSetLoad(race_buildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=SoundSetLoad(race_buildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=SoundSetLoad(race_buildings[r_uac ]+'nuclear_plant'  );

   snd_uac_suply            :=SoundSetLoad(race_buildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=SoundSetLoad(race_buildings[r_uac ]+'resourse_senter');

   snd_uac_hdeath           :=SoundSetLoad(race_units[r_uac ]+'death'              );

   snd_APC_ready            :=SoundSetLoad(race_units[r_uac ]+'APC\UAC_im_find2'   );
   snd_APC_move             :=SoundSetLoad(race_units[r_uac ]+'APC\uac_u'          );

   snd_bfgmarine_ready      :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=SoundSetLoad(race_units[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=SoundSetLoad(race_units[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=SoundSetLoad(race_units[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=SoundSetLoad(race_units[r_uac ]+'commando\attack'    );
   snd_commando_select      :=SoundSetLoad(race_units[r_uac ]+'commando\select'    );
   snd_commando_move        :=SoundSetLoad(race_units[r_uac ]+'commando\move'      );

   snd_engineer_ready       :=SoundSetLoad(race_units[r_uac ]+'engineer\ready'     );
   snd_engineer_annoy       :=SoundSetLoad(race_units[r_uac ]+'engineer\annoy'     );
   snd_engineer_attack      :=SoundSetLoad(race_units[r_uac ]+'engineer\attack'    );
   snd_engineer_select      :=SoundSetLoad(race_units[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=SoundSetLoad(race_units[r_uac ]+'engineer\move'      );

   snd_scout_ready          :=SoundSetLoad(race_units[r_uac ]+'scout\ready'        );
   snd_scout_select         :=SoundSetLoad(race_units[r_uac ]+'scout\select'       );
   snd_scout_move           :=SoundSetLoad(race_units[r_uac ]+'scout\go'           );

   snd_medic_ready          :=SoundSetLoad(race_units[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=SoundSetLoad(race_units[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=SoundSetLoad(race_units[r_uac ]+'medic\select'       );
   snd_medic_move           :=SoundSetLoad(race_units[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=SoundSetLoad(race_units[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=SoundSetLoad(race_units[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=SoundSetLoad(race_units[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=SoundSetLoad(race_units[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=SoundSetLoad(race_units[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=SoundSetLoad(race_units[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=SoundSetLoad(race_units[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=SoundSetLoad(race_units[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=SoundSetLoad(race_units[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=SoundSetLoad(race_units[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=SoundSetLoad(race_units[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=SoundSetLoad(race_units[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=SoundSetLoad(race_units[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=SoundSetLoad(race_units[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=SoundSetLoad(race_units[r_uac ]+'tank\attack'        );
   snd_tank_select          :=SoundSetLoad(race_units[r_uac ]+'tank\select'        );
   snd_tank_move            :=SoundSetLoad(race_units[r_uac ]+'tank\move'          );

   snd_uacbot_annoy         :=SoundSetLoad(race_units[r_uac ]+'uacbot\annoy'       );
   snd_uacbot_attack        :=SoundSetLoad(race_units[r_uac ]+'uacbot\attack'      );
   snd_uacbot_select        :=SoundSetLoad(race_units[r_uac ]+'uacbot\select'      );
   snd_uacbot_move          :=SoundSetLoad(race_units[r_uac ]+'uacbot\move'        );

   snd_terminator_ready     :=SoundSetLoad(race_units[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=SoundSetLoad(race_units[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=SoundSetLoad(race_units[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=SoundSetLoad(race_units[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=SoundSetLoad(race_units[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=SoundSetLoad(race_units[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=SoundSetLoad(race_units[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=SoundSetLoad(race_units[r_uac ]+'transport\select'   );
   snd_transport_move       :=SoundSetLoad(race_units[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=SoundSetLoad(race_units[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=SoundSetLoad(race_units[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=SoundSetLoad(race_units[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=SoundSetLoad(race_units[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=SoundSetLoad(race_units[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=SoundSetLoad(race_buildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=SoundSetLoad(race_buildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=SoundSetLoad(race_buildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=SoundSetLoad(race_buildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=SoundSetLoad(race_buildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=SoundSetLoad(race_buildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=SoundSetLoad(race_buildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=SoundSetLoad(race_buildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=SoundSetLoad(race_buildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=SoundSetLoad(race_buildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=SoundSetLoad(race_buildings[r_hell]+'hell_building' );
   snd_hell_eye             :=SoundSetLoad(race_buildings[r_hell]+'hell_eye'      );

   snd_hell                 :=SoundSetLoad(race_dir[r_hell]+'hell' );

   snd_hell_invuln          :=SoundSetLoad(race_units[r_hell]+'invuln');
   snd_hell_pain            :=SoundSetLoad(race_units[r_hell]+'d_p');
   snd_hell_melee           :=SoundSetLoad(race_units[r_hell]+'d_m');
   snd_hell_attack          :=SoundSetLoad(race_units[r_hell]+'d_a');
   snd_hell_move            :=SoundSetLoad(race_units[r_hell]+'d_' );

   snd_zimba_death          :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=SoundSetLoad(race_units[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=SoundSetLoad(race_units[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=SoundSetLoad(race_units[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=SoundSetLoad(race_units[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=SoundSetLoad(race_units[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=SoundSetLoad(race_units[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=SoundSetLoad(race_units[r_hell]+'knight\knightc');
   snd_knight_death         :=SoundSetLoad(race_units[r_hell]+'knight\knightd');
   snd_baron_ready          :=SoundSetLoad(race_units[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=SoundSetLoad(race_units[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=SoundSetLoad(race_units[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=SoundSetLoad(race_units[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=SoundSetLoad(race_units[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=SoundSetLoad(race_units[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=SoundSetLoad(race_units[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=SoundSetLoad(race_units[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=SoundSetLoad(race_units[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=SoundSetLoad(race_units[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=SoundSetLoad(race_units[r_hell]+'arachnotron\d_ar_c');


  {snd_transport       :=load_sound('inapc.wav'    );
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




