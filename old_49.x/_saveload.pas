

procedure _svld_pre;
var f :file;
   hp :byte;
   vr :integer=0;
   fn :shortstring;
   ms :cardinal;
   mw :word;
   pls:TPList;
begin
   ms:=0;
   vr:=0;
   mw:=0;
   hp:=0;
   FillChar(pls,Sizeof(pls),0);

   _svld_stat:='';

   fn:=str_svld_dir+_svld_l[_svld_ls]+str_svld_ext;
   if(_svld_l[_svld_ls]<>'')then
    if(FileExists(fn))then
    begin
       assign(f,fn);
       {$I-}reset(f,1);{$I+}
       if(ioresult<>0)then
       begin
          _svld_stat:=str_svld_errors[2];
          exit;
       end;
       if(FileSize(f)<>svld_size)then
       begin
          close(f);
          _svld_stat:=str_svld_errors[3];
          exit;
       end;
       BlockRead(f,Vr,SizeOf(ver));
       if(vr=Ver)then
       begin
         BlockRead(f,vr,sizeof(menu_s2));
         if(vr=ms2_camp)then
         begin
            BlockRead(f,vr,sizeof(_cmp_sel));
            if(0<=vr)and(vr<=MaxMissions)then
            begin
               _svld_stat:=str_camp_t[vr];
               BlockRead(f,vr,sizeof(cmp_skill));
               if(0<=vr)and(vr<=CMPMaxSkills)
               then _svld_stat:=_svld_stat+#11+str_cmpdif+#11+str_cmpd[vr]
               else _svld_stat:=str_svld_errors[4];
            end
            else _svld_stat:=str_svld_errors[4];
         end
         else
         begin
            BlockRead(f,vr,sizeof(_cmp_sel ));vr:=0;
            BlockRead(f,vr,sizeof(cmp_skill));vr:=0;

            BlockRead(f,ms,sizeof(map_seed ));_svld_stat:=str_map+': '+c2s(ms)+#13+' ';
            BlockRead(f,vr,sizeof(map_seed2));vr:=0;
            BlockRead(f,mw,sizeof(map_mw   ));_svld_stat:=_svld_stat+str_m_siz+w2s(mw)       +#13+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_liq  ));
            if(vr>7)then _svld_stat:=_svld_stat+str_m_liq+'??'
                    else _svld_stat:=_svld_stat+str_m_liq+_str_mx[vr]+#13+' ';vr:=0;
            BlockRead(f,vr,sizeof(map_lqt  ));vr:=0;
            BlockRead(f,vr,sizeof(map_trt  ));vr:=0;
            BlockRead(f,vr,sizeof(map_crt  ));vr:=0;
            BlockRead(f,vr,sizeof(map_hell ));vr:=0;
            BlockRead(f,vr,sizeof(map_obs  ));_svld_stat:=_svld_stat+str_m_obs+_str_mx[vr]+#13+' ';vr:=0;
            BlockRead(f,vr,sizeof(g_addon  ));_svld_stat:=_svld_stat+str_addon[vr>0]    +#13+' ';vr:=0;
            BlockRead(f,vr,sizeof(g_mode   ));_svld_stat:=_svld_stat+str_gmode[vr]      +#13+#25;vr:=0;
            BlockRead(f,vr,sizeof(g_startb ));vr:=0;
            BlockRead(f,vr,sizeof(g_shpos  ));vr:=0;
            BlockRead(f,hp,sizeof(HPlayer  ));

            BlockRead(f,pls,SizeOf(TPList));

            for vr:=1 to MaxPlayers do
            begin
               if(vr=hp)
               then _svld_stat:=_svld_stat+chr(vr)+'*'+#25+pls[vr].name
               else _svld_stat:=_svld_stat+chr(vr)+'#'+#25+pls[vr].name;

               if(pls[vr].state<>PS_None)
               then _svld_stat:=_svld_stat+','+str_race[pls[vr].mrace][2]+','+b2s(pls[vr].team)+#13
               else _svld_stat:=_svld_stat+#13;
            end;
         end;
      end
      else _svld_stat:=str_svld_errors[4];
      close(f);
   end
   else _svld_stat:=str_svld_errors[1];
end;

procedure _svld_sel;
begin
   if(0<=_svld_ls)and(_svld_ls<_svld_ln)then
   begin
      _svld_str:=_svld_l[_svld_ls];
      _svld_pre;
   end
   else
   begin
      _svld_str :='';
      _svld_stat:='';
   end;
end;

procedure _svld_make_lst;
var Info : TSearchRec;
       s : string;
begin
   _svld_sm:=0;
   _svld_ln:=0;
   setlength(_svld_l,0);
   if(FindFirst(str_svld_dir+'*'+str_svld_ext,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-3,4);
       if(s<>'')then
       begin
          _svld_ln+=1;
          setlength(_svld_l,_svld_ln);
          _svld_l[_svld_ln-1]:=s;
       end;
    until (FindNext(info)<>0);
   FindClose(info);

   _svld_sel;
end;

{
ver
menu_s2
_cmp_sel
cmp_skill
map_seed
map_seed2
map_mw
map_lqt
map_trt
map_crt
map_obs
map_hell
g_addon
g_mode
g_starta
g_sstart
PlayerHuman
_players
_units
_missiles
_effects
map_dds
vid_vx
vid_vy
plcolor
G_Step
vid_rtui
m_sbuild
g_inv_wn
g_inv_t
g_inv_wt
g_ct_pl
g_royal_r
ai_bx
ai_by
_uclord_c
_uregen_c
G_WTeam
team_army
ui_alrms
map_psx
map_psy
cmp_ait2p
}

procedure _svld_save;
var f:file;
begin
   assign(f,str_svld_dir+_svld_str+str_svld_ext);
   {$I-}rewrite(f,1);{$I+} if (ioresult<>0) then exit;


   BlockWrite(f,Ver        ,SizeOf(ver      ));
   BlockWrite(f,menu_s2    ,SizeOf(menu_s2  ));
   BlockWrite(f,_cmp_sel   ,SizeOf(_cmp_sel ));
   BlockWrite(f,cmp_skill  ,SizeOf(cmp_skill));
   BlockWrite(f,map_seed   ,SizeOf(map_seed ));
   BlockWrite(f,map_seed2  ,SizeOf(map_seed2));
   BlockWrite(f,map_mw     ,SizeOf(map_mw   ));
   BlockWrite(f,map_liq    ,SizeOf(map_liq  ));
   BlockWrite(f,map_lqt    ,SizeOf(map_lqt  ));
   BlockWrite(f,map_trt    ,SizeOf(map_trt  ));
   BlockWrite(f,map_crt    ,SizeOf(map_crt  ));
   BlockWrite(f,map_obs    ,SizeOf(map_obs  ));
   BlockWrite(f,map_hell   ,SizeOf(map_hell ));
   BlockWrite(f,g_addon    ,SizeOf(g_addon  ));
   BlockWrite(f,g_mode     ,SizeOf(g_mode   ));
   BlockWrite(f,g_startb   ,SizeOf(g_startb ));
   BlockWrite(f,g_shpos    ,SizeOf(g_shpos  ));
   BlockWrite(f,HPlayer    ,SizeOf(HPlayer  ));
   BlockWrite(f,_players   ,SizeOf(TPList   ));
   BlockWrite(f,_units     ,SizeOf(_units   ));
   BlockWrite(f,_missiles  ,SizeOf(_missiles));
   BlockWrite(f,_effects   ,SizeOf(_effects ));
   BlockWrite(f,map_dds    ,SizeOf(map_dds  ));
   BlockWrite(f,vid_vx     ,SizeOf(vid_vx   ));
   BlockWrite(f,vid_vy     ,SizeOf(vid_vy   ));
   BlockWrite(f,plcolor    ,SizeOf(plcolor  ));
   BlockWrite(f,G_Step     ,SizeOf(G_Step   ));
   BlockWrite(f,vid_rtui   ,SizeOf(vid_rtui ));
   BlockWrite(f,m_sbuild   ,SizeOf(m_sbuild ));
   BlockWrite(f,g_inv_wn   ,SizeOf(g_inv_wn ));
   BlockWrite(f,g_inv_t    ,SizeOf(g_inv_t  ));
   BlockWrite(f,g_inv_wt   ,SizeOf(g_inv_wt ));
   BlockWrite(f,g_cpoints  ,SizeOf(g_cpoints));
   BlockWrite(f,g_royal_r  ,SizeOf(g_royal_r));
   BlockWrite(f,_uclord_c  ,SizeOf(_uclord_c));
   BlockWrite(f,_uregen_c  ,SizeOf(_uregen_c));
   BlockWrite(f,G_WTeam    ,SizeOf(G_WTeam  ));
   BlockWrite(f,team_army  ,SizeOf(team_army));
   BlockWrite(f,ui_alrms   ,SizeOf(ui_alrms ));
   BlockWrite(f,map_psx    ,SizeOf(map_psx  ));
   BlockWrite(f,map_psy    ,SizeOf(map_psy  ));
   BlockWrite(f,cmp_ait2p  ,SizeOf(cmp_ait2p));

   close(f);

   _menu:=false;
   g_paused:=0;
   _svld_make_lst;

   net_chat_add(str_gsaved,HPlayer,255);
end;


procedure _svld_load;
var f:file;
   fn:shortstring;
   vr:byte=0;
begin
   if(_svld_ls<0)or(_svld_ls>=_svld_ln)then exit;

   fn:=str_svld_dir+_svld_l[_svld_ls]+str_svld_ext;
  if(_svld_l[_svld_ls]<>'')then
   if(FileExists(fn))then
   begin
      assign(f,fn);
      {$I-}reset(f,1);{$I+} if (ioresult<>0) then exit;
      if(FileSize(f)<>svld_size)then begin close(f); exit; end;
      BlockRead(f,Vr,SizeOf(ver));
      if(vr=Ver)then
      begin
         DefGameObjects;

         BlockRead(f,menu_s2    ,SizeOf(menu_s2  ));
         BlockRead(f,_cmp_sel   ,SizeOf(_cmp_sel ));
         BlockRead(f,cmp_skill  ,SizeOf(cmp_skill));
         BlockRead(f,map_seed   ,SizeOf(map_seed ));
         BlockRead(f,map_seed2  ,SizeOf(map_seed2));
         BlockRead(f,map_mw     ,SizeOf(map_mw   ));
         BlockRead(f,map_liq    ,SizeOf(map_liq  ));
         BlockRead(f,map_lqt    ,SizeOf(map_lqt  ));
         BlockRead(f,map_trt    ,SizeOf(map_trt  ));
         BlockRead(f,map_crt    ,SizeOf(map_crt  ));
         BlockRead(f,map_obs    ,SizeOf(map_obs  ));
         BlockRead(f,map_hell   ,SizeOf(map_hell ));
         BlockRead(f,g_addon    ,SizeOf(g_addon  ));
         BlockRead(f,g_mode     ,SizeOf(g_mode   ));
         BlockRead(f,g_startb   ,SizeOf(g_startb ));
         BlockRead(f,g_shpos    ,SizeOf(g_shpos  ));
         BlockRead(f,HPlayer    ,SizeOf(HPlayer  ));
         BlockRead(f,_players   ,SizeOf(TPList   ));
         BlockRead(f,_units     ,SizeOf(_units   ));
         BlockRead(f,_missiles  ,SizeOf(_missiles));
         BlockRead(f,_effects   ,SizeOf(_effects ));
         BlockRead(f,map_dds    ,SizeOf(map_dds  ));
         BlockRead(f,vid_vx     ,SizeOf(vid_vx   ));
         BlockRead(f,vid_vy     ,SizeOf(vid_vy   ));
         BlockRead(f,plcolor    ,SizeOf(plcolor  ));
         BlockRead(f,G_Step     ,SizeOf(G_Step   ));
         BlockRead(f,vid_rtui   ,SizeOf(vid_rtui ));
         BlockRead(f,m_sbuild   ,SizeOf(m_sbuild ));
         BlockRead(f,g_inv_wn   ,SizeOf(g_inv_wn ));
         BlockRead(f,g_inv_t    ,SizeOf(g_inv_t  ));
         BlockRead(f,g_inv_wt   ,SizeOf(g_inv_wt ));
         BlockRead(f,g_cpoints  ,SizeOf(g_cpoints));
         BlockRead(f,g_royal_r  ,SizeOf(g_royal_r));
         BlockRead(f,_uclord_c  ,SizeOf(_uclord_c));
         BlockRead(f,_uregen_c  ,SizeOf(_uregen_c));
         BlockRead(f,G_WTeam    ,SizeOf(G_WTeam  ));
         BlockRead(f,team_army  ,SizeOf(team_army));
         BlockRead(f,ui_alrms   ,SizeOf(ui_alrms ));
         BlockRead(f,map_psx    ,SizeOf(map_psx  ));
         BlockRead(f,map_psy    ,SizeOf(map_psy  ));
         BlockRead(f,cmp_ait2p  ,SizeOf(cmp_ait2p));

         map_vars;
         MakeTerrain;
         MakeLiquid;
         _refresh_dmcells;
         _makeMMB;
         _dds_spr;
         g_inv_calcmm;

         _view_bounds;
         G_Started:=true;
         _menu:=false;
      end;
      close(f);
   end;
end;

procedure _svld_delete;
var fn:string;
begin
   if(_svld_ls<0)or(_svld_ls>=_svld_ln)then exit;
   fn:=str_svld_dir+_svld_l[_svld_ls]+str_svld_ext;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      _svld_make_lst;
   end;
end;




