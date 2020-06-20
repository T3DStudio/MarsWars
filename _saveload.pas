
procedure _svld_pre;
var f :file;
   fn :string;
   vr,
   ml,
   mo,
   gm :byte;
   mw :integer;
   ms :word;
   pls:TPList;
begin
   ms:=0;
   vr:=0;
   mw:=0;
   ml:=0;
   mo:=0;
   gm:=0;

   _svld_stat:='';

   fn:=str_f_sv+_svld_l[_svld_ls]+str_e_sv;
   if(_svld_l[_svld_ls]<>'')then
    if(FileExists(fn)=false)
    then _svld_stat:=str_svld_errors[1]
    else
    begin
       {$I-}
       assign(f,fn);
       reset(f,1);
       {$I+}
       if(ioresult<>0)
       then _svld_stat:=str_svld_errors[2]
       else
       begin
          if(FileSize(f)<>svld_size)
          then _svld_stat:=str_svld_errors[3]
          else
          begin
             {$I-}
             BlockRead(f,vr,SizeOf(ver));
             if(vr<>Ver)
             then _svld_stat:=str_svld_errors[4]
             else
             begin
                BlockRead(f,vr,sizeof(menu_s2));
                if(vr=ms2_camp)then
                begin
                   //BlockRead(f,vr,sizeof(_cmp_sel));
                   //_svld_stat:=str_camp_t[vr];
                   //BlockRead(f,vr,sizeof(cmp_skill));
                   //_svld_stat:=_svld_stat+#11+str_cmpdif+#11+str_cmpd[vr];
                end
                else
                begin
                   //BlockRead(f,vr,sizeof(_cmp_sel));vr:=0;
                   //BlockRead(f,vr,sizeof(cmp_skill));vr:=0;

                   BlockRead(f,ms,sizeof(map_seed ));_svld_stat:=str_map+c2s(ms)+#13+' ';

                   BlockRead(f,mw,sizeof(map_mw  ));
                   BlockRead(f,ml,sizeof(map_liq ));
                   BlockRead(f,mo,sizeof(map_obs ));
                   BlockRead(f,gm,sizeof(g_mode  ));

                   if(mw<MinSMapW)or(mw>MaxSMapW)
                   or(ml>4)or(mo>4)or(gm>1)
                   then _svld_stat:=str_svld_errors[4]
                   else
                   begin
                      _svld_stat:=_svld_stat+str_m_siz+w2s(mw)   +#13+' ';
                      _svld_stat:=_svld_stat+str_m_liq+str_xN[ml]+#13+' ';
                      _svld_stat:=_svld_stat+str_m_obs+str_xN[mo]+#13+' ';
                      _svld_stat:=_svld_stat+str_gmode[gm]       +#13    ;

                      FillChar(pls,Sizeof(pls),0);
                      BlockRead(f,pls,SizeOf(TPList));

                      gm:=0;
                      BlockRead(f,gm,sizeof(HPlayer));

                      _svld_stat:=_svld_stat+str_players+':'+#13;

                      for vr:=1 to MaxPlayers do
                      with pls[vr] do
                      begin
                         ms:=0;
                         mw:=length(name);
                         while(mw>0)do
                          with pls[vr] do
                          begin
                             if(name[mw] in k_kbstr)then inc(ms,1);
                             dec(mw,1);
                          end;
                         while(ms<NameLen)do
                          with pls[vr] do
                          begin
                             name:=name+' ';
                             inc(ms,1);
                          end;

                         if(vr=HPlayer)
                         then _svld_stat:=_svld_stat+chr(vr)+'#='+#25+name
                         else _svld_stat:=_svld_stat+chr(vr)+'# '+#25+name;

                         if(state<>PS_None)
                         then _svld_stat:=_svld_stat+' '+str_race[mrace][1]+str_race[mrace][2]+#25+' '+b2s(team)+#13
                         else _svld_stat:=_svld_stat+#13;
                      end;

                       _svld_cor:=true;
                   end;
                end;
             end;
             {$I+}
          end;
          if(ioresult<>0)then
          begin
             _svld_stat:=str_svld_errors[4];
              _svld_cor:=false;
          end;
       end;

       close(f);
    end;
end;

procedure _svld_sel;
begin
   _svld_cor:=false;
   if(_svld_ls<_svld_ln)then
   begin
       if(_svld_ls<0)then _svld_ls:=0;
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
   if(FindFirst(str_f_sv+'*'+str_e_sv,faReadonly,info)=0)then
    repeat
       s:=info.Name;
       delete(s,length(s)-3,4);
       if(s<>'')then
       begin
          inc(_svld_ln,1);
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
//_cmp_sel
//cmp_skill
map_seed
map_mw
map_obs
g_mode
_players
G_Step
HPlayer
_units
//_missiles
//_effects
vid_vx
vid_vy
//vid_rtui
//m_sbuild
_uclord_c
_uregen_c
fog_ix0
fog_iy0
fog_ix1
fog_iy1
fog_c
//team_army
//ui_alrms
}

procedure _svld_save;
var f:file;
begin
   {$I-}
   assign(f,str_f_sv+_svld_str+str_e_sv);
   rewrite(f,1);
   {$I+}
   if(ioresult<>0)
   then _svld_stat:=str_svld_errors[2]
   else
   begin
      {$I-}
      BlockWrite(f,ver        ,SizeOf(ver));
      BlockWrite(f,menu_s2    ,SizeOf(menu_s2));
      //BlockWrite(f,_cmp_sel   ,SizeOf(_cmp_sel));
      //BlockWrite(f,cmp_skill  ,SizeOf(cmp_skill));
      BlockWrite(f,map_seed   ,SizeOf(map_seed));
      BlockWrite(f,map_mw     ,SizeOf(map_mw));
      BlockWrite(f,map_liq    ,SizeOf(map_liq));
      BlockWrite(f,map_obs    ,SizeOf(map_obs));
      BlockWrite(f,g_mode     ,SizeOf(g_mode));
      BlockWrite(f,_players   ,SizeOf(TPList));
      BlockWrite(f,HPlayer    ,SizeOf(HPlayer));
      BlockWrite(f,G_Step     ,SizeOf(G_Step));
      BlockWrite(f,_units     ,SizeOf(_units));
      //BlockWrite(f,_missiles  ,SizeOf(_missiles));
      BlockWrite(f,_effects   ,SizeOf(_effects));
      BlockWrite(f,vid_vx     ,SizeOf(vid_vx));
      BlockWrite(f,vid_vy     ,SizeOf(vid_vy));
      //BlockWrite(f,vid_rtui   ,SizeOf(vid_rtui));
      //BlockWrite(f,m_sbuild   ,SizeOf(m_sbuild));
      BlockWrite(f,_uclord_c  ,SizeOf(_uclord_c));
      BlockWrite(f,_uregen_c  ,SizeOf(_uregen_c));
{      BlockWrite(f,fog_ix0    ,SizeOf(fog_ix0));
      BlockWrite(f,fog_iy0    ,SizeOf(fog_iy0));
      BlockWrite(f,fog_ix1    ,SizeOf(fog_ix1));
      BlockWrite(f,fog_iy1    ,SizeOf(fog_iy1));
      BlockWrite(f,fog_c      ,SizeOf(fog_c)); }
      //BlockWrite(f,team_army  ,SizeOf(team_army));
      //BlockWrite(f,ui_alrms   ,SizeOf(ui_alrms));
      {$I+}

      if(ioresult<>0)
      then _svld_stat:=str_fileerw
      else
      begin
         net_chat_add(str_gsaved,HPlayer,0);
         _menu:=false;
         G_Status:=0;
         k_ml:=1;
      end;
   end;
   close(f);
   _svld_make_lst;
end;

procedure _svld_load;
var f:file;
   fn:string;
   vr:byte=0;
   u :integer;
begin
   fn:=str_f_sv+_svld_l[_svld_ls]+str_e_sv;

    _svld_sel;

   if(_svld_cor)then
   if(FileExists(fn))then
   begin
      {$I-}
      assign(f,fn);
      reset(f,1);
      {$I+}
      if(ioresult<>0)
      then _svld_stat:=str_svld_errors[2]
      else
      begin
         DefGameObjects;

         {$I-}
         BlockRead(f,vr,SizeOf(ver));
         BlockRead(f,menu_s2    ,SizeOf(menu_s2));
         //BlockRead(f,_cmp_sel   ,SizeOf(_cmp_sel));
         //BlockRead(f,cmp_skill  ,SizeOf(cmp_skill));
         BlockRead(f,map_seed   ,SizeOf(map_seed));
         BlockRead(f,map_mw     ,SizeOf(map_mw));
         BlockRead(f,map_liq    ,SizeOf(map_liq));
         BlockRead(f,map_obs    ,SizeOf(map_obs));
         BlockRead(f,g_mode     ,SizeOf(g_mode));
         BlockRead(f,_players   ,SizeOf(TPList));
         BlockRead(f,HPlayer    ,SizeOf(HPlayer));
         BlockRead(f,G_Step     ,SizeOf(G_Step));
         BlockRead(f,_units     ,SizeOf(_units));
         //BlockRead(f,_missiles  ,SizeOf(_missiles));
         BlockRead(f,_effects   ,SizeOf(_effects));
         BlockRead(f,vid_vx     ,SizeOf(vid_vx));
         BlockRead(f,vid_vy     ,SizeOf(vid_vy));
         //BlockRead(f,vid_rtui   ,SizeOf(vid_rtui));
         //BlockRead(f,m_sbuild   ,SizeOf(m_sbuild));
         BlockRead(f,_uclord_c  ,SizeOf(_uclord_c));
         BlockRead(f,_uregen_c  ,SizeOf(_uregen_c));
{         BlockRead(f,fog_ix0    ,SizeOf(fog_ix0));
         BlockRead(f,fog_iy0    ,SizeOf(fog_iy0));
         BlockRead(f,fog_ix1    ,SizeOf(fog_ix1));
         BlockRead(f,fog_iy1    ,SizeOf(fog_iy1));
         BlockRead(f,fog_c      ,SizeOf(fog_c));  }
         //BlockRead(f,team_army  ,SizeOf(team_army));
         //BlockRead(f,ui_alrms   ,SizeOf(ui_alrms));
         {$I+}

         if(ioresult<>0)then
         begin
            _svld_stat:=str_fileerr;
            Map_randommap;
            DefGameObjects;
            G_Started:=false;
         end
         else
         begin
            Map_premap;
            _draw_surf(spr_mback,ui_mmmpx,ui_mmmpy,ui_tminimap);
            _view_bounds;
            G_Started:=true;
            _menu:=false;
            k_ml:=1;

            for u:=1 to MaxUnits do
             with _units[u] do puid:=@_tuids[uid];
         end;
      end;
      close(f);
   end;
end;

procedure _svld_delete;
var fn:string;
begin
   fn:=str_f_sv+_svld_l[_svld_ls]+str_e_sv;
   if(FileExists(fn))then
   begin
      DeleteFile(fn);
      _svld_make_lst;
   end;
end;




