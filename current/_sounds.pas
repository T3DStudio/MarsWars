
procedure StopSoundSource(sss:byte);forward;
procedure SoundResetAllSources; forward;

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
   if(oalError)then
   begin
      Load_Chunk:=0;
      WriteLog(sfn+' alGenBuffers() error');
      exit;
   end;

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
   str:=folder_sound+fname;

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
function MusicSetLoad(dir:shortstring;count:integer):PTSoundSet;
var tsnd: PTMWSound;
    Info: TSearchRec;
    s   : shortstring;
flist_l : array of shortstring;
i,
flist_n : integer;
begin
   flist_n:=0;
   setlength(flist_l,0);
   if(FindFirst(folder_sound+dir+'*.ogg',faReadonly,info)=0)then
    repeat
      s:=info.Name;
      if(length(s)>4)then
      begin
         delete(s,length(s)-3,4);
         flist_n+=1;
         setlength(flist_l,flist_n);
         flist_l[flist_n-1]:=s;
      end;
    until(FindNext(info)<>0);
   FindClose(info);

   if(flist_n<count)then count:=flist_n;

   new(MusicSetLoad);
   with MusicSetLoad^ do
   begin
      sndps:=0;
      sndn :=0;
      setlength(snds,sndn);

      while(count>0)do
      begin
         repeat
            i:=random(flist_n);
         until length(flist_l[i])>0;

         tsnd:=load_sound(dir+flist_l[i]);
         if(tsnd<>nil)then SoundSetAdd(MusicSetLoad,tsnd);

         flist_l[i]:='';
         count-=1;
      end;
   end;
end;

procedure SoundSetUnLoad(sSet:PTSoundSet);
begin
   SoundResetAllSources;
   if(sSet=nil)then exit;
   with sSet^ do
   begin
      while(sndn>0)do
      begin
         sndn-=1;
         if alIsBuffer(snds[sndn]^.sound)then alDeleteBuffers(1,@(snds[sndn]^.sound));
      end;
      setlength(snds,0);
   end;
   dispose(sSet);
end;

procedure GameMusicReLoad;
begin
   StopSoundSource(sss_music);
   vid_LoadingScreen(@str_loading_msc,c_aqua);
   SoundSetUnLoad(snd_music_game);

   snd_music_game:=MusicSetLoad('music\game\',snd_musicListSize);
end;

procedure SoundShafleSoundSet(SoundSet:PTSoundSet);
var i,
m1,m2 : integer;
  snd : PTMWSound;
begin
   with SoundSet^ do
   begin
      sndps:=0;
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
end;

function SoundSetGetChunk(ss:PTSoundSet;NewChunk:boolean):PTMWSound;
begin
   SoundSetGetChunk:=nil;
   with ss^ do
    if(sndn>0)then
     if(sndn=1)
     then SoundSetGetChunk:=snds[0]
     else
     begin
        if(NewChunk)then sndps+=1;
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

procedure StopSoundSource(sss:byte);
var i:integer;
begin
   if(sss>=sss_count)then exit;

   with SoundSources[sss] do
    if(ssn>0)then
     for i:=0 to ssn-1 do
      with ssl[i] do alSourceStop(source);
end;

procedure SoundResetAllSources;
var sss,sn:byte;
begin
   for sss:=0 to sss_count-1 do
     with SoundSources[sss] do
       if(ssn>0)then
         for sn:=0 to ssn-1 do
           with ssl[sn] do
           begin
              alSourceStop(source);
              alSourcei   (source, AL_BUFFER, 0);
           end;
end;

procedure SoundPlay(SoundSet:PTSoundSet;sss:byte;NewChunk:boolean);
var vsound :PTMWSound;
    vsource:PTMWSoundSource;
begin
   if(sss>=sss_count)then exit;

   vsound :=SoundSetGetChunk(SoundSet,NewChunk);
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
   or(MainMenu)
   or(vid_draw=false)then exit;

   if(visdata<>nil)then
   begin
      if(visdata^=false)then exit;
   end
   else
     if(pu<>nil)then
       if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

   SoundPlay(ss,sss_world,true);
   SoundPlayUnit:=true;
end;

procedure SoundPlayUI(ss:PTSoundSet);
begin
   if(ss=nil)
   or(vid_draw=false)then exit;

   SoundPlay(ss,sss_ui,true);
end;

procedure SoundPlayAnoncer(ss:PTSoundSet;checkpause,stopother:boolean);
begin
   if(ss=nil)
   or(MainMenu)
   or(vid_draw=false)then exit;

   if(checkpause)and(snd_anoncer_last=ss)and(snd_anoncer_ticks>0)then exit;

   if(stopother)
   then StopSoundSource(sss_anoncer);
   SoundPlay(ss,sss_anoncer,true);

   snd_anoncer_ticks:=fr_fps1;
   snd_anoncer_last :=ss;
end;
procedure SoundPlayMMapAlarm(ss:PTSoundSet;checkpause:boolean);
begin
   if(ss=nil)
   or(MainMenu)
   or(vid_draw=false)then exit;

   if(checkpause)and(snd_mmap_last=ss)and(snd_mmap_ticks>0)then exit;

   SoundPlay(ss,sss_mmap,true);

   snd_mmap_ticks:=fr_fps10;
   snd_mmap_last :=ss;
end;

procedure SoundPlayUnitCommand(ss:PTSoundSet);
begin
   if(ss=nil)
   or(MainMenu)
   or(vid_draw=false)then exit;

   if(snd_command_last=ss)and(snd_command_ticks>0)then exit;

   SoundPlay(ss,sss_ucommand,true);

   snd_command_last:=ss;
   snd_command_ticks:=fr_fpst2;
end;

procedure SoundPlayUnitSelect;
const annoystart = 6;
      annoystop  = 12;
begin
   if(IsUnitRange(ui_UnitSelectedNU,nil))then
   begin
      if(ui_UnitSelectedNU<>ui_UnitSelectedPU)
      then ui_UnitSelectedn:=0
      else
        if(ui_UnitSelectedn<annoystop)
        then ui_UnitSelectedn+=1
        else ui_UnitSelectedn:=0;

      with g_units[ui_UnitSelectedNU] do
       with uid^ do
        if(uid_isbuilding)and(iscomplete=false)
        then SoundPlayUnitCommand(snd_building[uid_race])
        else
         if(ui_UnitSelectedn<annoystart)
         then SoundPlayUnitCommand(uid_snd_select)
         else SoundPlayUnitCommand(uid_snd_annoy );

      ui_UnitSelectedPU:=ui_UnitSelectedNU;
      ui_UnitSelectedNU:=0;
   end;
end;

procedure SoundLogUIPlayer(PListener:byte);
begin
   if(PListener<=LastPlayer)then
     with g_gplayers[PListener] do
       with log_l[log_i] do
         case lm_type of
0..LastPlayer         : if(lm_type<>PListener)then SoundPlayUI(snd_chat);
lmt_player_ready,
lmt_player_nready,
lmt_player_leave,
lmt_player_surrender,
lmt_chat_common,
lmt_game_PlayersReady,
lmt_game_StartsIn,
lmt_game_message      : SoundPlayUI(snd_chat);
// Basic
lmt_game_end          : if(lm_data_u<=LastPlayer)then
                          if(lm_data_u=team)
                          then SoundPlayAnoncer(snd_victory[race],false,true)
                          else SoundPlayAnoncer(snd_defeat [race],false,true);
lmt_player_defeated   : if(lm_data_u<=LastPlayer)and(g_status=gs_running)then
                        SoundPlayAnoncer(snd_player_defeated[race],true,false);
lmt_unit_LevelUp      : SoundPlayAnoncer(snd_unit_promoted  [race],true,false);
lmt_unit_resurrected,
lmt_unit_ready        : with g_uids[lm_data_u] do
                        SoundPlayUnitCommand(uid_snd_ready);
lmt_upgrade_complete  : SoundPlayAnoncer(snd_upgrade_complete[race],true,false);
lmt_prod_BadPlace     : SoundPlayAnoncer(snd_cannot_build    [race],true,false);
lmt_map_mark,
lmt_allies_attacked   : SoundPlayAnoncer(snd_mapmark,false,false);
lmt_unit_attacked     : with g_uids[lm_data_u] do
                        SoundPlayMMapAlarm(snd_under_attack[uid_isbuilding,race],true);
// Key Point Events
lmt_Req_Energy        : SoundPlayAnoncer(snd_not_enough_energy[race],true,false);
lmt_koth_control,
lmt_ngen_captured,
lmt_kpoint_captured   : SoundPlayAnoncer(snd_capture,true,false);
lmt_ngen_exh,
lmt_ngen_lost,
lmt_kpoint_lost       : SoundPlayAnoncer(snd_cplost,false,false);

lmt_invalid_Target,
lmt_ability_BadPlace,
lmt_ability_reload,
lmt_unit_NeedBuilder,
lmt_NeedProdUnit,
lmt_Req_MaxCount,
lmt_Req_Limit,
lmt_Req_Common,
lmt_prod_AllBusy,
lmt_upgrade_InProgress,
lmt_prod_BadOrder,
lmt_Invalid_Order     : SoundPlayAnoncer(snd_cant_order[race],true,false);


lmt_replay_RecStart,
lmt_replay_RecStop,
lmt_replay_RecError    :;  // no sound

         end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MUSIC
//

procedure SoundMusicControll(ForceNextTreck:boolean);
var current_music_ss: PTSoundSet;
begin
   if(G_Started)
   then current_music_ss:=snd_music_game
   else current_music_ss:=snd_music_menu;

   if(snd_music_current<>current_music_ss)or(not SoundSourceSetIsPlaying(@SoundSources[sss_music]))or(ForceNextTreck)then
   begin
      if(snd_music_current<>current_music_ss)and(not ForceNextTreck)then SoundShafleSoundSet(current_music_ss);
      snd_music_current:=current_music_ss;

      SoundPlay(snd_music_current,sss_music,true);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MAIN
//

procedure SoundControl;
begin
   if(ui_blink_timer1  =0)then SoundMusicControll(false);
   if(snd_anoncer_ticks>0)then snd_anoncer_ticks-=1;
   if(snd_command_ticks>0)then snd_command_ticks-=1;
   if(snd_mmap_ticks   >0)then snd_mmap_ticks   -=1;

   if(G_Started)and(G_status=gs_running)and(not MainMenu)then
     SoundPlayUnitSelect;
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

   GameMusicReLoad;
   snd_music_menu:=MusicSetLoad('music\menu\',snd_musicListSize);

   SoundShafleSoundSet(snd_music_menu);
   SoundShafleSoundSet(snd_music_game);
   /////////////////////////////////////////////////////////////////////////////////
   //
   // COMMON
   //

   vid_LoadingScreen(@str_loading_sfx,c_green);

   snd_click                :=SoundSetLoad('click'           );
   snd_chat                 :=SoundSetLoad('chat'            );
   snd_building_explode     :=SoundSetLoad('building_explode');
   snd_teleport             :=SoundSetLoad('teleport'        );
   snd_exp                  :=SoundSetLoad('explode'         );
   snd_transport            :=SoundSetLoad('inapc'           );
   snd_meat                 :=SoundSetLoad('meat'            );
   snd_cube                 :=SoundSetLoad('cube_s'          );
   snd_mapmark              :=SoundSetLoad('mapmark'         );
   snd_capture              :=SoundSetLoad('capture'         );
   snd_cplost               :=SoundSetLoad('cplost'          );

   snd_pexp                 :=SoundSetLoad(folder_missiles+'p_exp'           );
   snd_launch               :=SoundSetLoad(folder_missiles+'launch'          );
   snd_pistol               :=SoundSetLoad(folder_missiles+'pistol'          );
   snd_shotgun              :=SoundSetLoad(folder_missiles+'shotgun'         );
   snd_ssg                  :=SoundSetLoad(folder_missiles+'ssg'             );
   snd_plasma               :=SoundSetLoad(folder_missiles+'plasma'          );
   snd_bfg_shot             :=SoundSetLoad(folder_missiles+'bfg_shot'        );
   snd_healing              :=SoundSetLoad(folder_missiles+'healing'         );
   snd_electro              :=SoundSetLoad(folder_missiles+'electro'         );
   snd_rico                 :=SoundSetLoad(folder_missiles+'rico'            );
   snd_bfg_exp              :=SoundSetLoad(folder_missiles+'bfg_exp'         );
   snd_flyer_s              :=SoundSetLoad(folder_missiles+'flyer_s'         );
   snd_flyer_a              :=SoundSetLoad(folder_missiles+'flyer_a'         );

   for r:=1 to r_cnt do
   begin
   snd_under_attack[true ,r]:=SoundSetLoad(folder_Race[r]+'base_under_attack'         );
   snd_under_attack[false,r]:=SoundSetLoad(folder_Race[r]+'unit_under_attack'         );
   snd_build_place       [r]:=SoundSetLoad(folder_Race[r]+'build_place'               );
   snd_building          [r]:=SoundSetLoad(folder_Race[r]+'building'                  );
   snd_constr_complete   [r]:=SoundSetLoad(folder_Race[r]+'construction_complete'     );
   snd_cannot_build      [r]:=SoundSetLoad(folder_Race[r]+'cannot_build_here'         );
   snd_defeat            [r]:=SoundSetLoad(folder_Race[r]+'defeat'                    );
   snd_not_enough_energy [r]:=SoundSetLoad(folder_Race[r]+'not_enough_energy'         );
   snd_player_defeated   [r]:=SoundSetLoad(folder_Race[r]+'player_defeated'           );
   snd_upgrade_complete  [r]:=SoundSetLoad(folder_Race[r]+'upgrade_complete'          );
   snd_victory           [r]:=SoundSetLoad(folder_Race[r]+'victory'                   );
   snd_unit_adv          [r]:=SoundSetLoad(folder_Race[r]+'unit_adv'                  );
   snd_unit_promoted     [r]:=SoundSetLoad(folder_Race[r]+'unit_promoted'             );
   snd_cant_order        [r]:=SoundSetLoad(folder_Race[r]+'cant_order'                );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_radar                :=SoundSetLoad(folder_Race[r_uac]+'radar');

   snd_jetpon               :=SoundSetLoad(folder_Race[r_uac]+'jetpon'    );
   snd_CCup                 :=SoundSetLoad(folder_Race[r_uac]+'ccup'      );
   snd_bomblaunch           :=SoundSetLoad(folder_Race[r_uac]+'bomblaunch');

   snd_uac_mine             :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'mine' );

   snd_uac_cc               :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'generator'      );
   snd_uac_smith            :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'factory'        );
   snd_uac_tech             :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'nuclear_plant'  );

   snd_uac_suply            :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=SoundSetLoad(folder_RaceBuildings[r_uac ]+'resourse_senter');

   snd_uac_hdeath           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'death'              );

   snd_APC_ready            :=SoundSetLoad(folder_RaceUnits[r_uac ]+'APC\UAC_im_find2'   );
   snd_APC_move             :=SoundSetLoad(folder_RaceUnits[r_uac ]+'APC\uac_u'          );

   snd_bfgmarine_ready      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\attack'    );
   snd_commando_select      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\select'    );
   snd_commando_move        :=SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\move'      );

   snd_engineer_ready       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\ready'     );
   snd_engineer_annoy       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\annoy'     );
   snd_engineer_attack      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\attack'    );
   snd_engineer_select      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\move'      );

   snd_scout_ready          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'scout\ready'        );
   snd_scout_select         :=SoundSetLoad(folder_RaceUnits[r_uac ]+'scout\select'       );
   snd_scout_move           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'scout\go'           );

   snd_medic_ready          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\select'       );
   snd_medic_move           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\attack'        );
   snd_tank_select          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\select'        );
   snd_tank_move            :=SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\move'          );

   snd_uacbot_annoy         :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\annoy'       );
   snd_uacbot_attack        :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\attack'      );
   snd_uacbot_select        :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\select'      );
   snd_uacbot_move          :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\move'        );

   snd_terminator_ready     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\select'   );
   snd_transport_move       :=SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_building' );
   snd_hell_eye             :=SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_eye'      );

   snd_hell                 :=SoundSetLoad(folder_Race[r_hell]+'hell' );

   snd_hell_invuln          :=SoundSetLoad(folder_RaceUnits[r_hell]+'invuln');
   snd_hell_pain            :=SoundSetLoad(folder_RaceUnits[r_hell]+'d_p');
   snd_hell_melee           :=SoundSetLoad(folder_RaceUnits[r_hell]+'d_m');
   snd_hell_attack          :=SoundSetLoad(folder_RaceUnits[r_hell]+'d_a');
   snd_hell_move            :=SoundSetLoad(folder_RaceUnits[r_hell]+'d_' );

   snd_zimba_death          :=SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=SoundSetLoad(folder_RaceUnits[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=SoundSetLoad(folder_RaceUnits[r_hell]+'knight\knightc');
   snd_knight_death         :=SoundSetLoad(folder_RaceUnits[r_hell]+'knight\knightd');
   snd_baron_ready          :=SoundSetLoad(folder_RaceUnits[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=SoundSetLoad(folder_RaceUnits[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=SoundSetLoad(folder_RaceUnits[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=SoundSetLoad(folder_RaceUnits[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_c');

   InitSound:=true;
end;




