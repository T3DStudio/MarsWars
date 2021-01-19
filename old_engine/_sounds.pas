

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
      end;
   end;
end;

function LoadSoundSet(fname:shortstring):PTSoundSet;
var tsnd:PTMWSound;
begin
   new(LoadSoundSet);
   with LoadSoundSet^ do
   begin
      sndn:=0;
      setlength(snds,sndn);

      tsnd:=loadSND(fname);
      if(tsnd<>nil)then
      begin
         inc(sndn,1);
         setlength(snds,sndn);
         snds[sndn-1]:=tsnd;
      end;

      while true do
      begin
         tsnd:=loadSND(fname+i2s(sndn));
         if(tsnd=nil)then break;

         inc(sndn,1);
         setlength(snds,sndn);
         snds[sndn-1]:=tsnd;
      end;
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
     SoundSet2Chunk:=snds[random(sndn)];
end;

function PlaySoundSet(ss:PTSoundSet):PTMWSound;
begin
   PlaySoundSet:=SoundSet2Chunk(ss);
   if(PlaySoundSet<>nil)then
    with PlaySoundSet^ do
    begin
       MIX_VOLUMECHUNK(sound,snd_svolume);
       last_channel:=MIX_PLAYCHANNEL(-1,sound,0);
    end;
end;

procedure PlaySND(ss:PTSoundSet;pu:PTUnit);
begin
   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(pu<>nil)then
    with pu^ do
     if(_nhp3(x,y,player)=false)then exit;

   PlaySoundSet(ss);
end;

procedure PlaySNDM(ss:PTSoundSet);
begin
   if(ss=nil)
   or(_draw=false)then exit;

   PlaySoundSet(ss);
end;

procedure PlayInGameAnoncer(ss:PTSoundSet);
const min_pause = fr_fps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(snd_anoncer_pause<min_pause)then
    if(snd_anoncer_pause<=0)or(snd_anoncer_last<>ss)then
    begin
       s:=PlaySoundSet(ss);
       if(s<>nil)then
       begin
          snd_anoncer_last :=ss;
          snd_anoncer_pause:=max2(min_pause,s^.ticks_length);
       end;
    end;
end;

procedure PlayUnitSound(ss:PTSoundSet);
const min_pause = fr_hfps;
var s:PTMWSound;
begin
   if(ss=nil)
   or(_menu)
   or(_draw=false)then exit;

   if(snd_unit_cmd_pause<min_pause)then
   begin
      s:=SoundSet2Chunk(ss);
      if(s<>nil)then
       if(snd_unit_cmd_pause<=0)or(snd_unit_cmd_last<>s)then
       begin
          mix_haltchannel(s^.last_channel);
          mix_playchannel(s^.last_channel,s^.sound,0);
          snd_unit_cmd_last :=s;
          snd_unit_cmd_pause:=max2(min_pause,s^.ticks_length);
       end;
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

   if(SDL_Init(SDL_INIT_AUDIO)<>0)then begin WriteError; exit; end;

   if(MIX_OPENAUDIO(AUDIO_FREQUENCY,
                    AUDIO_FORMAT,
                    AUDIO_CHANNELS,
                    AUDIO_CHUNKSIZE  )<>0) then begin WriteError; exit; end;

   LoadAllMusic;
   ShafleMusicList;

   snd_click:=LoadSoundSet('click');
   snd_chat :=LoadSoundSet('chat' );

   for r:=1 to r_cnt do
   begin
   snd_under_attack[true ,r]:=LoadSoundSet(race_dir[r]+'base_under_attack'    );
   snd_under_attack[false,r]:=LoadSoundSet(race_dir[r]+'unit_under_attack'    );
   snd_build_place       [r]:=LoadSoundSet(race_dir[r]+'build_place'          );
   snd_building          [r]:=LoadSoundSet(race_dir[r]+'building'             );
   snd_constr_complete   [r]:=LoadSoundSet(race_dir[r]+'construction_complete');
   snd_cannot_build      [r]:=LoadSoundSet(race_dir[r]+'cannot_build_here'    );
   snd_defeat            [r]:=LoadSoundSet(race_dir[r]+'defeat'               );
   snd_not_enough_energy [r]:=LoadSoundSet(race_dir[r]+'not_enough_energy'    );
   snd_player_defeated   [r]:=LoadSoundSet(race_dir[r]+'player_defeated'      );
   snd_upgrade_complete  [r]:=LoadSoundSet(race_dir[r]+'upgrade_complete'     );
   snd_victory           [r]:=LoadSoundSet(race_dir[r]+'victory'              );
   end;

   snd_teleport    :=LoadSoundSet('teleport' );
   snd_pexp        :=LoadSoundSet('p_exp'    );
   snd_exp         :=LoadSoundSet('explode'  );
   snd_exp2        :=LoadSoundSet('explode2' );




   {snd_inapc       :=loadSND('inapc.wav'    );
   snd_ccup        :=loadSND('ccup.wav'     );
   snd_radar       :=loadSND('radar.wav'    );  }
   {snd_meat        :=loadSND('gv.wav'       );
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




