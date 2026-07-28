
procedure snd_StopSoundSource(sss:byte);forward;
procedure snd_SoundResetAllSources; forward;

////////////////////////////////////////////////////////////////////////////////
//
//   LOAD
//

function oalError:boolean;begin oalError:=alGetError()<>AL_NO_ERROR;end;

function snd_LoadChunk(fname:shortstring):TALuint;
var str,stre : shortstring;
SLformat: TALenum = 0;
SLdata  : TALvoid = nil;
SLsize  : TALsizei= 0;
SLfreq  : TALsizei= 0;
SLloop  : TALint  = 0;

procedure load_wav(sfn:shortstring);
begin
   oalError();

   alGenBuffers   (1,    @snd_LoadChunk);
   if(oalError)then begin snd_LoadChunk:=0;exit;end;
   alutLoadWAVFile(sfn   ,SLformat,SLdata,SLsize,SLfreq,SLloop);
   if(oalError)then begin snd_LoadChunk:=0;exit;end;
   alBufferData   (snd_LoadChunk,SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then begin snd_LoadChunk:=0;exit;end;
   alutUnloadWAV  (       SLformat,SLdata,SLsize,SLfreq);
   if(oalError)then snd_LoadChunk:=0;
end;

procedure snd_LoadOGG(sfn:shortstring);
var
SLformat: TALenum     = 0;
SLdata  : TALvoid     = nil;
SLsize  : TALsizei    = 0;
SLfreq  : TALsizei    = 0;
error   : shortstring = '';
begin
   oalError();

   alGenBuffers(1,@snd_LoadChunk);
   if(oalError)then
   begin
      snd_LoadChunk:=0;
      WriteLog(sfn+' alGenBuffers() error');
      exit;
   end;

   if(LoadOGGData(sfn,@SLformat,@SLdata,@SLsize,@SLfreq,@error))then
   begin
      alBufferData(snd_LoadChunk,SLformat,SLdata,SLsize,SLfreq);
      if(oalError)then snd_LoadChunk:=0;
      FreeOGGData(@SLdata,@SLsize);
   end
   else
   begin
      WriteLog(sfn+' '+error);
      alDeleteBuffers(1,@snd_LoadChunk);
      snd_LoadChunk:=0;
   end;
end;

begin
   snd_LoadChunk:=0;
   str:=folder_sound+fname;

   stre:=str+'.wav';
   if FileExists(stre)then
   begin
      load_wav(stre);
      if(snd_LoadChunk=0)then WriteLog(stre+' error!');
      exit;
   end;

   stre:=str+'.ogg';
   if FileExists(stre)then
   begin
      snd_LoadOGG(stre);
      if(snd_LoadChunk=0)then WriteLog(stre+' error!');
      exit;
   end;
end;


function snd_LoadSound(fn:shortstring):PTMWSound;
var t:TALuint;
begin
   snd_LoadSound:=nil;
   t:=snd_LoadChunk(fn);
   if(t<>0)then
   begin
      new(snd_LoadSound);
      snd_LoadSound^.oal_sound:=t;
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SoundSets
//

procedure snd_SoundSetAdd(asset:PTSoundSet;asnd:PTMWSound);
begin
   if(asnd<>nil)then
     with asset^ do
     begin
        snd_sset_n+=1;
        setlength(snd_sset_l,snd_sset_n);
        snd_sset_l[snd_sset_n-1]:=asnd;
     end;
end;

function snd_SoundSetLoad(fname:shortstring):PTSoundSet;
var
tsnd:PTMWSound;
   i:integer;
begin
   i:=0;
   new(snd_SoundSetLoad);
   with snd_SoundSetLoad^ do
   begin
      snd_sset_c:=0;
      snd_sset_n :=0;
      setlength(snd_sset_l,snd_sset_n);

      tsnd:=snd_LoadSound(fname);
      if(tsnd<>nil)then snd_SoundSetAdd(snd_SoundSetLoad,tsnd);

      while true do
      begin
         tsnd:=snd_LoadSound(fname+i2s(i));
         if(tsnd=nil)then
          if(i=0)then
          begin
             i+=1;
             continue;
          end
          else break;

         snd_SoundSetAdd(snd_SoundSetLoad,tsnd);
         i+=1;
      end;
      if(snd_sset_n<=0)then WriteLog(fname);
   end;
end;
function snd_MusicSetLoad(dir:shortstring;count:integer):PTSoundSet;
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

   new(snd_MusicSetLoad);
   with snd_MusicSetLoad^ do
   begin
      snd_sset_c:=0;
      snd_sset_n :=0;
      setlength(snd_sset_l,snd_sset_n);

      while(count>0)do
      begin
         repeat
            i:=random(flist_n);
         until length(flist_l[i])>0;

         tsnd:=snd_LoadSound(dir+flist_l[i]);
         if(tsnd<>nil)then snd_SoundSetAdd(snd_MusicSetLoad,tsnd);

         flist_l[i]:='';
         count-=1;
      end;
   end;
end;

procedure snd_SoundSetUnLoad(sSet:PTSoundSet);
begin
   snd_SoundResetAllSources;
   if(sSet=nil)then exit;
   with sSet^ do
   begin
      while(snd_sset_n>0)do
      begin
         snd_sset_n-=1;
         if alIsBuffer(snd_sset_l[snd_sset_n]^.oal_sound)then alDeleteBuffers(1,@(snd_sset_l[snd_sset_n]^.oal_sound));
      end;
      setlength(snd_sset_l,0);
   end;
   dispose(sSet);
end;

procedure snd_SoundShafleSoundSet(SoundSet:PTSoundSet);
var i,
m1,m2 : integer;
  snd : PTMWSound;
begin
   with SoundSet^ do
   begin
      snd_sset_c:=0;
      if(snd_sset_n>1)then
       for i:=0 to snd_sset_n+5 do
       begin
          m1:=random(snd_sset_n);
          m2:=random(snd_sset_n);

          snd:=snd_sset_l[m1];
          snd_sset_l[m1]:=snd_sset_l[m2];
          snd_sset_l[m2]:=snd;
          snd_sset_c:=random(snd_sset_n);
       end;
   end;
end;

procedure snd_GameMusicReLoad;
begin
   snd_StopSoundSource(sss_music);
   draw_LoadingScreen(@str_loading_msc,c_aqua);
   snd_SoundSetUnLoad(snd_music_game);

   snd_music_game:=snd_MusicSetLoad(folder_music_game,snd_musicListSize);
   snd_SoundShafleSoundSet(snd_music_game);
end;

function snd_SoundSetGetChunk(ss:PTSoundSet;NewChunk:boolean):PTMWSound;
begin
   snd_SoundSetGetChunk:=nil;
   with ss^ do
     if(snd_sset_n>0)then
       if(snd_sset_n=1)
       then snd_SoundSetGetChunk:=snd_sset_l[0]
       else
       begin
          if(NewChunk)then snd_sset_c+=1;
          if(snd_sset_c<0)or(snd_sset_c>=snd_sset_n)then snd_sset_c:=0;
          snd_SoundSetGetChunk:=snd_sset_l[snd_sset_c];
       end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   SOURCE SETs
//

procedure snd_SoundSourceSetInit(sss:PTMWSoundSourceSet;sssn:integer;avolumevar:psingle);
begin
   if(sssn>0)then
     with sss^ do
     begin
        setlength(snd_srcset_l,sssn);
        snd_srcset_n:=sssn;

        while(sssn>0)do
        begin
           sssn-=1;
           with snd_srcset_l[sssn] do
           begin
              alGenSources(1,@snd_src_source);
              alSourcefv(snd_src_source, AL_POSITION, @SLpos);
              snd_src_volumevar:=avolumevar;
           end;
        end;
     end;
end;

procedure snd_SoundSourceUpdateGain(SoundSourceSet:PTMWSoundSourceSet);
var i:integer;
begin
   with SoundSourceSet^ do
     if(snd_srcset_n>0)then
       for i:=0 to snd_srcset_n-1 do
         with snd_srcset_l[i] do
           if(snd_src_volumevar<>nil)then alSourcef(snd_src_source,AL_GAIN,snd_src_volumevar^);
end;
procedure snd_SoundSourceUpdateGainAll;
var s:integer;
begin
   for s:=0 to sss_count-1 do snd_SoundSourceUpdateGain(@SoundSources[s]);
end;

function snd_SourceIsPlaying(source:TALuint):boolean;
var i:TALint;
begin
   alGetSourcei(source,AL_SOURCE_STATE,@i);
   snd_SourceIsPlaying:=(i=AL_PLAYING);
end;
function snd_SoundSourceSetIsPlaying(SoundSourceSet:PTMWSoundSourceSet):boolean;
var i:integer;
begin
   snd_SoundSourceSetIsPlaying:=false;

   with SoundSourceSet^ do
    if(snd_srcset_n>0)then
     for i:=0 to snd_srcset_n-1 do
      with snd_srcset_l[i] do
       if(snd_SourceIsPlaying(snd_src_source))then
       begin
          snd_SoundSourceSetIsPlaying:=true;
          break;
       end;
end;

function snd_SoundSourceSetGetSource(SoundSourceSet:PTMWSoundSourceSet):PTMWSoundSource;
var i:integer;
begin
   snd_SoundSourceSetGetSource:=nil;

   with SoundSourceSet^ do
     if(snd_srcset_n>0)then
       if(snd_srcset_n=1)
       then snd_SoundSourceSetGetSource:=@snd_srcset_l[0]
       else
         for i:=0 to snd_srcset_n-1 do
           with snd_srcset_l[i] do
             if(snd_SourceIsPlaying(snd_src_source)=false)then snd_SoundSourceSetGetSource:=@snd_srcset_l[i];
end;

////////////////////////////////////////////////////////////////////////////////
//
//   PLAY
//

procedure snd_StopSoundSource(sss:byte);
var i:byte;
begin
   if(sss>=sss_count)then exit;

   with SoundSources[sss] do
    if(snd_srcset_n>0)then
     for i:=0 to snd_srcset_n-1 do
      with snd_srcset_l[i] do alSourceStop(snd_src_source);
end;

procedure snd_StopSoundSourceAll;
var i:byte;
begin
   for i:=0 to sss_count-1 do
     if(i<>sss_music)then
       snd_StopSoundSource(i);
end;

procedure snd_SoundResetAllSources;
var sss,sn:byte;
begin
   for sss:=0 to sss_count-1 do
     with SoundSources[sss] do
       if(snd_srcset_n>0)then
         for sn:=0 to snd_srcset_n-1 do
           with snd_srcset_l[sn] do
           begin
              alSourceStop(snd_src_source);
              alSourcei   (snd_src_source, AL_BUFFER, 0);
           end;
end;

procedure snd_SoundPlay(SoundSet:PTSoundSet;sss:byte;NewChunk:boolean);
var vsound :PTMWSound;
    vsource:PTMWSoundSource;
begin
   if(sss>=sss_count)then exit;

   vsound :=snd_SoundSetGetChunk(SoundSet,NewChunk);
   vsource:=snd_SoundSourceSetGetSource(@SoundSources[sss]);

   if(vsound<>nil)and(vsource<>nil)then
   with vsound^  do
   with vsource^ do
   begin
      alSourceStop(snd_src_source);

      if(snd_src_volumevar<>nil)then
      alSourcef   (snd_src_source, AL_GAIN  , snd_src_volumevar^);

      alSourcei   (snd_src_source, AL_BUFFER, oal_sound  );
      alSourcePlay(snd_src_source);
   end;
end;

function snd_SoundPlayUnit(ss:PTSoundSet;pu:PTUnit;visdata:pboolean):boolean;
begin
   snd_SoundPlayUnit:=false;
   if(ss=nil)
   or(MainMenu)
   or(not vid_draw)then exit;

   if(visdata<>nil)then
   begin
      if(not visdata^)then exit;
   end
   else
     if(pu<>nil)then
       if(not ui_CheckUnitUIPlayerVision(pu,true))then exit;

   snd_SoundPlay(ss,sss_world,true);
   snd_SoundPlayUnit:=true;
end;

procedure snd_SoundPlayUI(ss:PTSoundSet);
begin
   if(ss=nil)
   or(not vid_draw)then exit;

   snd_SoundPlay(ss,sss_ui,true);
end;

procedure snd_SoundPlayAnoncer(ss:PTSoundSet;checkpause,stopother:boolean);
begin
   if(ss=nil)
   //or(MainMenu)
   or(not vid_draw)then exit;

   if(checkpause)and(snd_anoncer_last=ss)and(snd_anoncer_ticks>0)then exit;

   if(stopother)
   then snd_StopSoundSource(sss_anoncer);
   snd_SoundPlay(ss,sss_anoncer,true);

   snd_anoncer_ticks:=fr_fps1;
   snd_anoncer_last :=ss;
end;
procedure snd_SoundPlayMMapAlarm(ss:PTSoundSet;checkpause:boolean);
begin
   if(ss=nil)
   or(MainMenu)
   or(not vid_draw)then exit;

   if(checkpause)and(snd_mmap_last=ss)and(snd_mmap_ticks>0)then exit;

   snd_SoundPlay(ss,sss_mmap,true);

   snd_mmap_ticks:=fr_fps10;
   snd_mmap_last :=ss;
end;

procedure snd_SoundPlayUnitCommand(ss:PTSoundSet);
begin
   if(ss=nil)
   or(MainMenu)
   or(not vid_draw)then exit;

   if(snd_command_last=ss)and(snd_command_ticks>0)then exit;

   snd_SoundPlay(ss,sss_ucommand,true);

   snd_command_last:=ss;
   snd_command_ticks:=fr_fpst2;
end;

procedure snd_SoundPlayUnitSelect;
begin
   if(ui_CommandercPU<>nil)then
     with ui_CommandercPU^ do
     with uid^ do
     begin
        if(ui_CommanderpPU<>ui_CommandercPU)
        then ui_UnitSelSoundA:=uid_snd_select^.snd_sset_n
        else
          if(ui_UnitSelSoundA>0)
          then ui_UnitSelSoundA-=1
          else
            if(ui_UnitSelSoundA=0)
            then ui_UnitSelSoundA:=-uid_snd_annoy^.snd_sset_n
            else
            begin
               ui_UnitSelSoundA+=1;
               if(ui_UnitSelSoundA=0)then ui_UnitSelSoundA:=uid_snd_select^.snd_sset_n
            end;
        ui_CommanderpPU:=ui_CommandercPU;

        case iscomplete of
        false: if(uid_isbuilding)then
               begin
                  snd_SoundPlayUnitCommand(snd_building[uid_race]);
                  exit;
               end;
        true : if(transformTimer>0)then
               begin
                  if(g_uids[transformUID].uid_isbuilding)
                  then snd_SoundPlayUnitCommand(snd_building[uid_race])
                  else snd_SoundPlayUnitCommand(uid_snd_select);
                  exit;
               end;
        end;

        if(ui_UnitSelSoundA>=0)
        then snd_SoundPlayUnitCommand(uid_snd_select)
        else snd_SoundPlayUnitCommand(uid_snd_annoy );
     end;
end;

procedure snd_SoundLogUIPlayer(PListener:byte);
begin
   if(PListener<=LastPlayer)then
     with g_PlayersGame[PListener] do
       with log_l[log_i] do
         case lm_type of
lmt_chat_player0..
lmt_chat_player7        : if((lm_type-lmt_chat_player0)<>PListener)then snd_SoundPlayUI(snd_chat);
lmt_player_leave        : if(not g_started)
                          or(g_PlayersGame[LocalPlayer].isobserver)then snd_SoundPlayUI(snd_chat);
//lmt_chat_local,
lmt_game_message        : snd_SoundPlayUI(snd_chat   );
lmt_game_ReadyToStart   : snd_SoundPlayUI(snd_PowerUp);
lmt_game_BreakStarting  : ;
lmt_game_StartsIn,
lmt_game_ResetIn        : snd_SoundPlayUI(snd_Stink  );
// Basic

lmt_game_end            : if(lm_data_u<=LastPlayer)then
                            if(lm_data_u=team)
                            then snd_SoundPlayAnoncer(snd_victory[race],false,true)
                            else snd_SoundPlayAnoncer(snd_defeat [race],false,true);
lmt_game_Paused         : snd_SoundPlayAnoncer(snd_SwitchOn ,false,true);
lmt_game_Resumed        : snd_SoundPlayAnoncer(snd_SwitchOff,false,true);
lmt_player_revealed,
lmt_player_surrender    : snd_SoundPlayAnoncer(snd_chat,false,true);
lmt_player_ready,
lmt_player_nready       : ;
lmt_player_defeated     : if(lm_data_u<=LastPlayer)and(g_status=gs_running)then
                          snd_SoundPlayAnoncer(snd_player_defeated[race],true,false);
lmt_unit_LevelUp        : snd_SoundPlayAnoncer(snd_unit_promoted  [race],true,false);
lmt_unit_readyU,
lmt_unit_readyB         : with g_uids[lm_data_u] do
                          snd_SoundPlayUnitCommand(uid_snd_ready);
lmt_unit_resurrected,
lmt_unit_captured       : with g_uids[lm_data_u] do
                          if(uid_isbuilding)
                          then snd_SoundPlayUnitCommand(uid_snd_select)
                          else snd_SoundPlayUnitCommand(uid_snd_ready );

lmt_upgrade_complete    : snd_SoundPlayAnoncer(snd_upgrade_complete[race],true ,false);
lmt_prod_BadPlace       : snd_SoundPlayAnoncer(snd_cannot_build    [race],true ,false);

// minimap
lmt_allies_attackedU,
lmt_allies_attackedB    : snd_SoundPlayMMapAlarm(snd_mapmark,false);
lmt_unit_attackedU,
lmt_unit_attackedB      : with g_uids[lm_data_u] do
                          snd_SoundPlayMMapAlarm(snd_under_attack[uid_isbuilding,race],true);
lmt_other_UACScan,
lmt_markAttack          : snd_SoundPlayMMapAlarm(snd_mapmark,false);
lmt_markLook            : snd_SoundPlayMMapAlarm(snd_Stink  ,false);

// Key Point Events
lmt_koth_Alarm          : if(s2b(lm_string)>10)
                          then snd_SoundPlayAnoncer(snd_KeyPointAlarm,false,true)
                          else snd_SoundPlayAnoncer(snd_Stink,false,true);
lmt_koth_CaptureStart,
lmt_kpoint_CaptureStart : snd_SoundPlayMMapAlarm(snd_KeyPointAlarm   ,false);
lmt_kpoint_Captured     : if(lm_data_u=team)
                          then snd_SoundPlayMMapAlarm(snd_KeyPointCaptured,false)
                          else snd_SoundPlayMMapAlarm(snd_KeyPointLost    ,false);
lmt_ngen_captured       : snd_SoundPlayMMapAlarm(snd_GeneratorCapture,false);
lmt_ngen_exh,
lmt_ngen_lost           : snd_SoundPlayMMapAlarm(snd_GeneratorLost   ,false);
lmt_ngen_alarm          : snd_SoundPlayMMapAlarm(snd_GeneratorAlarm  ,false);

// other
lmt_Req_Energy          : snd_SoundPlayAnoncer(snd_not_enough_energy[race],true,false);

lmt_invalid_Target,
lmt_ability_BadPlace,
lmt_ability_reload,
lmt_ability_casting,
lmt_ability_ReqUACNear,
lmt_ability_ReqHelNear,
lmt_ability_Tar2Close,
lmt_unit_NeedBuilder,
lmt_unit_lost,
lmt_unit_NeedProdUnit,
lmt_Req_MaxCount,
lmt_Req_MaxBuilders,
lmt_Req_Limit,
lmt_Req_Common,
lmt_Req_HellPower,
lmt_Req_UACLoot,
lmt_upgrade_InProgress,
lmt_prod_AllBusy,
lmt_prod_BadOrder,
lmt_prod_CD,
lmt_prod_Unavailable,
lmt_Invalid_Order       : snd_SoundPlayAnoncer(snd_cant_order[race],true,false);


lmt_replay_RecStart,
lmt_replay_RecStop,
lmt_replay_RecError     :;  // no sound

         end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MUSIC
//

procedure snd_SoundMusicControll(ForceNextTreck:boolean);
var current_music_ss: PTSoundSet;
begin
   if(g_started)
   then current_music_ss:=snd_music_game
   else current_music_ss:=snd_music_menu;

   if(snd_music_current<>current_music_ss)or(not snd_SoundSourceSetIsPlaying(@SoundSources[sss_music]))or(ForceNextTreck)then
   begin
      if(snd_music_current<>current_music_ss)and(not ForceNextTreck)then snd_SoundShafleSoundSet(current_music_ss);
      snd_music_current:=current_music_ss;

      snd_SoundPlay(snd_music_current,sss_music,true);
   end;
end;

////////////////////////////////////////////////////////////////////////////////
//
//   MAIN
//

procedure snd_SoundControl;
begin
   if(ui_blink_timer1  =0)then snd_SoundMusicControll(false);
   if(snd_anoncer_ticks>0)then snd_anoncer_ticks-=1;
   if(snd_command_ticks>0)then snd_command_ticks-=1;
   if(snd_mmap_ticks   >0)then snd_mmap_ticks   -=1;

   if(g_started)and(g_status=gs_running)and(not MainMenu)and(ui_UnitSelSound)then
   begin
      snd_SoundPlayUnitSelect;
      ui_UnitSelSound:=false;
   end;
end;


function InitSound:boolean;
var r:integer;
begin
   InitSound:=false;

   if(not InitOpenAL)then exit;

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
     sss_music: snd_SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_mvolume1);
     else       snd_SoundSourceSetInit(@SoundSources[r],sss_sssize[r],@snd_svolume1);
     end;

   snd_GameMusicReLoad;
   snd_music_menu:=snd_MusicSetLoad(folder_music_menu,snd_musicListSize);

   snd_SoundShafleSoundSet(snd_music_menu);
   snd_SoundShafleSoundSet(snd_music_game);

   /////////////////////////////////////////////////////////////////////////////////
   //
   // COMMON
   //

   draw_LoadingScreen(@str_loading_sfx,c_green);

   snd_click                :=snd_SoundSetLoad('click'           );
   snd_chat                 :=snd_SoundSetLoad('chat'            );
   snd_explode              :=snd_SoundSetLoad('explode'         );
   snd_explode_bfg          :=snd_SoundSetLoad('explode_bfg'     );
   snd_explode_building     :=snd_SoundSetLoad('explode_building');
   snd_explode_flyer        :=snd_SoundSetLoad('explode_flyer'   );
   snd_explode_plasma       :=snd_SoundSetLoad('explode_plasma'  );
   snd_Gibs                 :=snd_SoundSetLoad('Gibs'            );
   snd_Healing              :=snd_SoundSetLoad('healing'         );
   snd_IconOfSinCube        :=snd_SoundSetLoad('IconOfSinCube'   );
   snd_KeyPointCaptured     :=snd_SoundSetLoad('KeyPointCaptured');
   snd_KeyPointLost         :=snd_SoundSetLoad('KeyPointLost'    );
   snd_KeyPointAlarm        :=snd_SoundSetLoad('KeyPointAlarm'   );
   snd_GeneratorCapture     :=snd_SoundSetLoad('GeneratorCapture');
   snd_GeneratorLost        :=snd_SoundSetLoad('GeneratorLost'   );
   snd_GeneratorAlarm       :=snd_SoundSetLoad('GeneratorAlarm'  );

   snd_mapmark              :=snd_SoundSetLoad('MapMark'         );
   snd_PowerUp              :=snd_SoundSetLoad('PowerUp'         );
   snd_SwitchOn             :=snd_SoundSetLoad('SwitchOn'        );
   snd_SwitchOff            :=snd_SoundSetLoad('SwitchOff'       );
   snd_Stink                :=snd_SoundSetLoad('Stink'           );
   snd_repairing            :=snd_SoundSetLoad('repairing'       );
   snd_rico                 :=snd_SoundSetLoad('rico'            );
   snd_shot_bfg             :=snd_SoundSetLoad('shot_bfg'        );
   snd_shot_flyer           :=snd_SoundSetLoad('shot_flyer'      );
   snd_shot_pistol          :=snd_SoundSetLoad('shot_pistol'     );
   snd_shot_plasma          :=snd_SoundSetLoad('shot_plasma'     );
   snd_shot_rocket          :=snd_SoundSetLoad('shot_rocket'     );
   snd_shot_shotgun         :=snd_SoundSetLoad('shot_shotgun'    );
   snd_shot_ssg             :=snd_SoundSetLoad('shot_ssg'        );
   snd_Teleport             :=snd_SoundSetLoad('Teleport'        );
   snd_Transport            :=snd_SoundSetLoad('Transport'       );

   for r:=1 to r_count do
   begin
   snd_under_attack[true ,r]:=snd_SoundSetLoad(folder_Race[r]+'base_under_attack'    );
   snd_under_attack[false,r]:=snd_SoundSetLoad(folder_Race[r]+'unit_under_attack'    );
   snd_build_place       [r]:=snd_SoundSetLoad(folder_Race[r]+'build_place'          );
   snd_building          [r]:=snd_SoundSetLoad(folder_Race[r]+'building'             );
   snd_constr_complete   [r]:=snd_SoundSetLoad(folder_Race[r]+'construction_complete');
   snd_cannot_build      [r]:=snd_SoundSetLoad(folder_Race[r]+'cannot_build_here'    );
   snd_defeat            [r]:=snd_SoundSetLoad(folder_Race[r]+'defeat'               );
   snd_not_enough_energy [r]:=snd_SoundSetLoad(folder_Race[r]+'not_enough_energy'    );
   snd_player_defeated   [r]:=snd_SoundSetLoad(folder_Race[r]+'player_defeated'      );
   snd_upgrade_complete  [r]:=snd_SoundSetLoad(folder_Race[r]+'upgrade_complete'     );
   snd_victory           [r]:=snd_SoundSetLoad(folder_Race[r]+'victory'              );
   snd_unit_adv          [r]:=snd_SoundSetLoad(folder_Race[r]+'unit_adv'             );
   snd_unit_promoted     [r]:=snd_SoundSetLoad(folder_Race[r]+'unit_promoted'        );
   snd_cant_order        [r]:=snd_SoundSetLoad(folder_Race[r]+'cant_order'           );
   snd_rally_point       [r]:=snd_SoundSetLoad(folder_Race[r]+'new_rally_point'      );
   snd_select_target     [r]:=snd_SoundSetLoad(folder_Race[r]+'select_target'        );
   end;

   /////////////////////////////////////////////////////////////////////////////////
   //
   // UAC
   //

   snd_RadarScan            :=snd_SoundSetLoad(folder_Race[r_uac]+'radar');

   snd_JetPackOn            :=snd_SoundSetLoad(folder_Race[r_uac]+'JetPackOn'    );
   snd_CCenterLiftUp        :=snd_SoundSetLoad(folder_Race[r_uac]+'CCenterLiftUp');
   snd_bomblaunch           :=snd_SoundSetLoad(folder_Race[r_uac]+'bomblaunch'   );

   snd_uac_cc               :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'command_center' );
   snd_uac_barracks         :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'barraks'        );
   snd_uac_generator        :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'generator'      );
   snd_uac_forge            :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'weapon_factory' );
   snd_uac_ctower           :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'chaingun_tower' );
   snd_uac_radar            :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'radar_on'       );
   snd_uac_rtower           :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'rocket_turret'  );
   snd_uac_factory          :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'factory'        );
   snd_uac_tech             :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'tech_center'    );
   snd_uac_rls              :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'rocketstation'  );
   snd_uac_nucl             :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'nuclear_plant'  );
   snd_uac_academy          :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'academy'        );

   snd_uac_suply            :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'supply-depot'   );
   snd_uac_rescc            :=snd_SoundSetLoad(folder_RaceBuildings[r_uac ]+'resourse_senter');

   snd_uac_inf_death        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'inf_death'          );
   snd_uac_inf_pain1        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'inf_pain1'          );
   snd_uac_inf_pain2        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'inf_pain2'          );
   snd_uac_inf_pain3        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'inf_pain3'          );
   snd_uac_inf_pain4        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'inf_pain4'          );
   snd_uac_mec_pain1        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'mech_pain1'         );
   snd_uac_mec_pain2        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'mech_pain2'         );
   snd_uac_mec_pain3        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'mech_pain3'         );

   snd_bfgmarine_ready      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\ready'    );
   snd_bfgmarine_annoy      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\an'       );
   snd_bfgmarine_attack     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\attack'   );
   snd_bfgmarine_select     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\select'   );
   snd_bfgmarine_move       :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'bfgmarine\go'       );

   snd_commando_ready       :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\ready'     );
   snd_commando_annoy       :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\annoy'     );
   snd_commando_attack      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\attack'    );
   snd_commando_select      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\select'    );
   snd_commando_move        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'commando\move'      );

   snd_aairmarine_ready     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'antiaircrafter\ready' );
   snd_aairmarine_annoy     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'antiaircrafter\annoy' );
   snd_aairmarine_attack    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'antiaircrafter\attack');
   snd_aairmarine_select    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'antiaircrafter\select');
   snd_aairmarine_move      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'antiaircrafter\move'  );

   snd_engineer_ready       :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\ready'     );
   snd_engineer_select      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\select'    );
   snd_engineer_move        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'engineer\go'        );

   snd_medic_ready          :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\ready'        );
   snd_medic_annoy          :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\annoy'        );
   snd_medic_select         :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\select'       );
   snd_medic_move           :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'medic\move'         );

   snd_plasmamarine_ready   :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\ready' );
   snd_plasmamarine_annoy   :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\annoy' );
   snd_plasmamarine_attack  :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\attack');
   snd_plasmamarine_select  :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\select');
   snd_plasmamarine_move    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'plasmamarine\move'  );

   snd_rocketmarine_ready   :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_ready');
   snd_rocketmarine_annoy   :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_irr'  );
   snd_rocketmarine_attack  :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_atk'  );
   snd_rocketmarine_select  :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_sel'  );
   snd_rocketmarine_move    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'rocketmarine\rocket_conf' );

   snd_shotgunner_ready     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\ready'   );
   snd_shotgunner_annoy     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\an'      );
   snd_shotgunner_attack    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\attack'  );
   snd_shotgunner_select    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\select'  );
   snd_shotgunner_move      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'shotgunner\go'      );

   snd_ssg_ready            :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\ready'          );
   snd_ssg_annoy            :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\annoy'          );
   snd_ssg_attack           :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\attack'         );
   snd_ssg_select           :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\select'         );
   snd_ssg_move             :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'ssg\move'           );

   snd_tank_ready           :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\ready'         );
   snd_tank_annoy           :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\annoy'         );
   snd_tank_attack          :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\attack'        );
   snd_tank_select          :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\select'        );
   snd_tank_move            :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'tank\move'          );

   snd_uacbot_annoy         :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\annoy'       );
   snd_uacbot_attack        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\attack'      );
   snd_uacbot_select        :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\select'      );
   snd_uacbot_move          :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacbot\move'        );

   snd_terminator_ready     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\ready'   );
   snd_terminator_annoy     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\annoy'   );
   snd_terminator_attack    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\attack'  );
   snd_terminator_select    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\select'  );
   snd_terminator_move      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'terminator\move'    );

   snd_transport_ready      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\ready'    );
   snd_transport_annoy      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\annoy'    );
   snd_transport_select     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\select'   );
   snd_transport_move       :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'transport\move'     );

   snd_uacfighter_ready     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\ready'   );
   snd_uacfighter_annoy     :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\an'      );
   snd_uacfighter_attack    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\attack'  );
   snd_uacfighter_select    :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\select'  );
   snd_uacfighter_move      :=snd_SoundSetLoad(folder_RaceUnits[r_uac ]+'uacfighter\go'      );


   /////////////////////////////////////////////////////////////////////////////////
   //
   // HELL
   //

   snd_hell_hk              :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_keep'     );
   snd_hell_hgate           :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_gate'     );
   snd_hell_hsymbol         :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_symbol'   );
   snd_hell_hpool           :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_pool'     );
   snd_hell_htower          :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_tower'    );
   snd_hell_hteleport       :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_teleport' );
   snd_hell_htotem          :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_totem'    );
   snd_hell_hmon            :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_monastery');
   snd_hell_hfort           :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_temple'   );
   snd_hell_haltar          :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_altar'    );
   snd_hell_hbuild          :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_building' );
   snd_hell_eye             :=snd_SoundSetLoad(folder_RaceBuildings[r_hell]+'hell_eye'      );

   snd_hell                 :=snd_SoundSetLoad(folder_Race[r_hell]+'hell' );

   snd_hell_pain            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'d_p');
   snd_hell_melee           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'d_m');
   snd_hell_attack          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'d_a');
   snd_hell_move            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'d_' );

   snd_zimba_death          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_d' );
   snd_zimba_ready          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_s' );
   snd_zimba_pain           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_p' );
   snd_zimba_move           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'zimbas\d_z_ac');

   snd_revenant_death       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_d' );
   snd_revenant_ready       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_c' );
   snd_revenant_melee       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_m' );
   snd_revenant_attack      :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_a' );
   snd_revenant_move        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'revenant\d_rev_ac');

   snd_pain_ready           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_c');
   snd_pain_death           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_d');
   snd_pain_pain            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'pain\d_pain_p');

   snd_mastermind_ready     :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_c');
   snd_mastermind_death     :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_d');
   snd_mastermind_foot      :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mastermind\d_u6_f');

   snd_mancubus_ready       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_c');
   snd_mancubus_death       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_d');
   snd_mancubus_pain        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_p');
   snd_mancubus_attack      :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'mancubus\d_man_a');

   snd_lost_move            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'lost\d_u0'     );

   snd_knight_ready         :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'knight\knightc');
   snd_knight_death         :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'knight\knightd');
   snd_baron_ready          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'baron\d_u4_c'  );
   snd_baron_death          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'baron\d_u4_d'  );

   snd_imp_ready            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_u1_s');
   snd_imp_death            :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_u1_d');
   snd_imp_move             :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'imp\d_imp' );

   snd_demon_ready          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2'   );
   snd_demon_death          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2_d' );
   snd_demon_melee          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'demon\d_u2_a' );

   snd_cyber_ready          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5'   );
   snd_cyber_death          :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5_d' );
   snd_cyber_foot           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'cyber\d_u5_f' );

   snd_caco_death           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'caco\d_u3_d'   );
   snd_caco_ready           :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'caco\d_u3'     );

   snd_archvile_death       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_d' );
   snd_archvile_attack      :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_at');
   snd_archvile_fire        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_f' );
   snd_archvile_pain        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_p' );
   snd_archvile_ready       :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_c' );
   snd_archvile_move        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'archvile\d_arch_a' );

   snd_arachno_death        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_d');
   snd_arachno_move         :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_act');
   snd_arachno_foot         :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_f');
   snd_arachno_ready        :=snd_SoundSetLoad(folder_RaceUnits[r_hell]+'arachnotron\d_ar_c');

   InitSound:=true;
end;




