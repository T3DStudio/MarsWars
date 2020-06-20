
{function loadMSC(fn:shortstring):pMIX_MUSIC;
begin
   loadMSC:=nil;

   fn:=str_f_msc+fn+#0;
   loadMSC:=MIX_LOADMUS(@fn[1]);

   if(loadMSC=nil)then WriteError(fn);
end;  }

function loadSND(fn:shortstring):pMIX_CHUNK;
begin
   loadSND:=nil;

   fn:=str_f_snd+fn+#0;
   loadSND:=mix_loadwav(@fn[1]);

   if(loadSND=nil)then WriteError(fn);
end;

{procedure PlayMSC(m:pMIX_MUSIC);
begin
   if(snd_usesnd=false)then exit;

   MIX_PLAYMUSIC(m,0);
   MIX_VOLUMEMUSIC(snd_mvolume);
end; }

procedure PlayGSND(s:pMIX_CHUNK);
begin
   writeln(1);
   if(s=nil)or(snd_usesnd=false)then exit;
   writeln(snd_svolume);

   MIX_VOLUMECHUNK(s,snd_svolume);
   MIX_PLAYCHANNEL(-1,s,0);
end;

procedure PlayUSND(s:pMIX_CHUNK;pu:PTUnit=nil);
begin
   if(s=nil)or(snd_usesnd=false)or(_rpls_step>1)or(_menu)then exit;

   if(pu<>nil)then
    with(pu^)do
     with _players[player] do
      if(_nhp3(vx,vy,team)=false)then exit;

   MIX_VOLUMECHUNK(s,snd_svolume);
   MIX_PLAYCHANNEL(-1,s,0);
end;

function _ueff2snd(uid,stp:byte;adv:boolean):pMIX_CHUNK;
var i:byte;
begin
   _ueff2snd:=nil;
   with _tuids[uid] do
    case _ueffsndn[adv,stp] of
    0:;
    1:   _ueff2snd:=_ueffsnds[adv,stp,0];
    else _ueff2snd:=_ueffsnds[adv,stp,random(_ueffsndn[adv,stp])]
    end;
end;

{procedure PlayTSND(uid,stp:byte);
var i:byte;
begin
   with _tuids[uid] do
    if(_ueffsndn[stp]>0)then PlaySND(_ueffsnds[stp,random(_ueffsndn[stp])]);
end;  }

{procedure PlaySSND(pu:PTUnit;stp:byte);
begin
   if(pu=nil)or(snd_usesnd=false)or(_rpls_step>1)or(_menu)then exit;

   with(pu^)do
   begin
      with _players[player] do
       if(_nhp3(vx,vy,team)=false)then exit;

      PlayTSND(uid,stp);
   end;
end;  }



{procedure _MusicCheck;
begin
   if(snd_usesnd=false)then exit;
   if(snd_mls>0)then
    if(Mix_PlayingMusic>0)then
    begin
       if(G_started)and(snd_curm=0)and(snd_mls>1)then
       begin
          snd_curm:=1+random(snd_mls-1);
          PlayMSC(snd_ml[snd_curm]);
       end
       else
         if(G_started=false)and(snd_curm>0)then
         begin
            snd_curm:=0;
            PlayMSC(snd_ml[snd_curm]);
         end;
    end
    else
    begin
       if(G_started)and(snd_mls>1)then
       begin
          inc(snd_curm,1);
          if(snd_curm>=snd_mls)then snd_curm:=1;
       end
       else snd_curm:=0;
       PlayMSC(snd_ml[snd_curm]);
    end;
end;
procedure load_music;
var Info : TSearchRec;
       s : shortstring;
begin
   snd_mls:=0;
   setlength(snd_ml,0);

   if(FindFirst(str_f_msc+'*.ogg',faReadonly,info)=0)then
    repeat
       s:=info.Name;
       if(s<>'')then
       begin
          setlength(snd_ml,snd_mls+1);
          snd_ml[snd_mls]:=loadMSC(s);
          Inc(snd_mls,1);
       end;
    until (FindNext(info)<>0);
   FindClose(info);
end;

procedure shaflemusic;
var i,m1,m2:byte;
    d:pMIX_MUSIC;
begin
   if(snd_mls>3)then
    for i:=1 to snd_mls do
    begin
       m1:=random(snd_mls-1)+1;
       m2:=random(snd_mls-1)+1;
       d:=snd_ml[m1];
       snd_ml[m1]:=snd_ml[m2];
       snd_ml[m2]:=d;
    end;
end;}

procedure _InitSound;
begin
   snd_usesnd:=false;

   if (SDL_Init(SDL_INIT_AUDIO)<>0) then begin WriteError(SDL_GetError);exit;end;

   if (MIX_OPENAUDIO(AUDIO_FREQUENCY, AUDIO_FORMAT,AUDIO_CHANNELS, AUDIO_CHUNKSIZE)<>0) then begin WriteError(SDL_GetError);exit;end;

   //load_music;
   //shaflemusic;

   snd_click       :=loadSND('click.wav');
   snd_chat        :=loadSND('chat.wav');
   snd_dron0       :=loadSND('dron0.wav');
   snd_dron1       :=loadSND('dron1.wav');
   snd_inapc       :=loadSND('inapc.wav');
   snd_ccup        :=loadSND('ccup.wav');
   snd_radar       :=loadSND('radar.wav');
   snd_teleport    :=loadSND('teleport.wav');
   snd_pexp        :=loadSND('p_exp.wav');
   snd_exp         :=loadSND('explode.wav');
   snd_exp2        :=loadSND('explode2.wav');
   snd_meat        :=loadSND('gv.wav');
   snd_d0          :=loadSND('d_u0.wav');
   snd_ar_act      :=loadSND('d_ar_act.wav');
   snd_ar_d        :=loadSND('d_ar_d.wav');
   snd_ar_c        :=loadSND('d_ar_c.wav');
   snd_ar_f        :=loadSND('d_ar_f.wav');
   snd_arch_a      :=loadSND('d_arch_a.wav');
   snd_arch_at     :=loadSND('d_arch_at.wav');
   snd_arch_d      :=loadSND('d_arch_d.wav');
   snd_arch_p      :=loadSND('d_arch_p.wav');
   snd_arch_c      :=loadSND('d_arch_c.wav');
   snd_arch_f      :=loadSND('d_arch_f.wav');
   snd_demonc      :=loadSND('d_u2.wav');
   snd_demona      :=loadSND('d_u2_a.wav');
   snd_demond      :=loadSND('d_u2_d.wav');
   snd_hmelee      :=loadSND('d_melee.wav');
   snd_demon1      :=loadSND('d_0.wav');
   snd_imp         :=loadSND('d_imp.wav');
   snd_impd1       :=loadSND('d_u1_d1.wav');
   snd_impd2       :=loadSND('d_u1_d2.wav');
   snd_impc1       :=loadSND('d_u1_s1.wav');
   snd_impc2       :=loadSND('d_u1_s2.wav');
   snd_dpain       :=loadSND('d_p.wav');
   snd_cacoc       :=loadSND('d_u3.wav');
   snd_cacod       :=loadSND('d_u3_d.wav');
   snd_baronc      :=loadSND('d_u4.wav');
   snd_barond      :=loadSND('d_u4_d.wav');
   snd_knight      :=loadSND('knight.wav');
   snd_knightd     :=loadSND('knightd.wav');
   snd_cyberc      :=loadSND('d_u5.wav');
   snd_cyberd      :=loadSND('d_u5_d.wav');
   snd_cyberf      :=loadSND('d_u5_f.wav');
   snd_mindc       :=loadSND('d_u6.wav');
   snd_mindd       :=loadSND('d_u6_d.wav');
   snd_mindf       :=loadSND('d_u6_f.wav');
   snd_pain_c      :=loadSND('d_pain_c.wav');
   snd_pain_p      :=loadSND('d_pain_p.wav');
   snd_pain_d      :=loadSND('d_pain_d.wav');
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
   snd_hshoot      :=loadSND('d_a.wav'    );
   snd_rev_c       :=loadSND('d_rev_c.wav');
   snd_rev_m       :=loadSND('d_rev_m.wav');
   snd_rev_d       :=loadSND('d_rev_d.wav');
   snd_rev_a       :=loadSND('d_rev_a.wav');
   snd_rev_ac      :=loadSND('d_rev_ac.wav'    );
   snd_cubes       :=loadSND('cube_s.wav'      );
   snd_launch      :=loadSND('launch.wav'      );
   snd_pistol      :=loadSND('h_u0_a.WAV'      );
   snd_shotgun     :=loadSND('h_u1_a.wav'      );
   snd_rico        :=loadSND('rico1.wav'       );
   snd_ssg         :=loadSND('ssg.wav'         );
   snd_bfgs        :=loadSND('h_u5_a.wav'      );
   snd_bfgepx      :=loadSND('bfg_exp.wav'     );
   snd_plasmas     :=loadSND('h_u4_a.wav'      );
   snd_cast2       :=loadSND('rep.wav'         );
   snd_cast        :=loadSND('h_u0_r.WAV'      );
   snd_uupgr       :=loadSND('uup.WAV'         );
   snd_hupgr       :=loadSND('hup.WAV'         );
   snd_alarm       :=loadSND('alarm.wav'       );
   snd_hellbar     :=loadSND('hellbarracks.wav');
   snd_hell        :=loadSND('hell.wav'        );
   snd_ubuild      :=loadSND('build.wav'       );

   snd_usesnd      :=true;
end;




