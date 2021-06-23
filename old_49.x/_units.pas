
{$IFDEF _FULLGAME}
procedure _unit_dvis(u:integer);
var spr : PTUSprite;
begin
   with _units[u] do
    with _players[player] do
     if(hits>dead_hits)then
     begin
        if(hits<idead_hits)then exit;

        spr:=_unit_spr(@_units[u]);

        if(spr=@spr_dummy)then exit;

        if(_unit_fogrev(u))then
         if ((vid_vx+vid_panel-spr^.hw)<vx)and(vx<(vid_vx+vid_mw+spr^.hw))and
            ((vid_vy          -spr^.hh)<vy)and(vy<(vid_vy+vid_mh+spr^.hh))then
         begin
            anim:=abs(hits-idead_hits);
            if(anim>255)then anim:=255;
            _sl_add(vx-spr^.hw, vy-spr^.hh,_udpth(u),0,0,0,false,spr^.surf,anim,0,0,0,0,'',0);
         end;
     end;
end;

procedure _unit_deff(u:integer;deff:boolean);
begin
   with _units[u] do
   with _players[player] do
   begin
      if(deff)then
      begin
         if(isbuild)then
         begin
            case uid of
            UID_Mine:
            begin
               PlaySND(snd_exp,u);
               _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Exp);
            end;
            UID_HEye:
            begin
               PlaySND(snd_pexp,u);
               _effect_add(vx,vy-6,map_flydpth[uf]+vy,UID_HEye);
            end
            else
               if(uf=uf_ground)then
                if(race=r_hell)and(hits<200)and(bld=false)then
                begin
                   if(r<41)
                   then _effect_add(vx,vy+5 ,-5,eid_db_h1)
                   else _effect_add(vx,vy+10,-5,eid_db_h0);
                   exit;
                end;
               PlaySND(snd_exp2,u);
               if(r>48)then
               begin
                  _effect_add(vx,vy,map_flydpth[uf]+vy,EID_BBExp);
                  if(uf=uf_ground)then
                   if(race=r_hell)
                   then _effect_add(vx,vy+10,-10,eid_db_h0)
                   else _effect_add(vx,vy+10,-10,eid_db_u0);
               end
               else
               begin
                  _effect_add(vx,vy,map_flydpth[uf]+vy,EID_BExp);
                  if(uf=uf_ground)then
                   if(race=r_hell)
                   then _effect_add(vx,vy+10,-10,eid_db_h1)
                   else _effect_add(vx,vy+10,-10,eid_db_u1);
               end;
            end;
         end
         else
         case uid of
           UID_LostSoul : begin
                             PlaySND(snd_pexp,u);
                             _effect_add(vx,vy,map_flydpth[uf]+vy,UID_LostSoul);
                          end;
           UID_Pain     : begin
                             PlaySND(snd_pain_d,u);
                             _effect_add(vx,vy,map_flydpth[uf]+vy,UID_Pain);
                             if(OnlySVCode)then
                              if(buff[ub_advanced]>0)then
                              begin
                                 _pain_lost(u,vx-10+random(20),vy-10+random(20));
                                 _pain_lost(u,vx-10+random(20),vy-10+random(20));
                                 _pain_lost(u,vx-10+random(20),vy-10+random(20));
                              end;
                          end;
         else
           if(uid in gavno)then
            if(uf>uf_ground)then
            begin
               PlaySND(snd_exp,u);
               _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Exp);
            end
            else
            begin
               PlaySND(snd_meat,u);
               _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Gavno);
            end
           else
            case uid of
        UID_APC,
        UID_FAPC   : begin
                        PlaySND(snd_exp,u);
                        _effect_add(vx,vy,map_flydpth[uf]+vy,EID_BExp);
                     end;
        UID_Flyer,
        UID_Terminator,
        UID_Tank   : begin
                        PlaySND(snd_exp,u);
                        _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Exp2);
                     end;
        UID_UTransport:
                     begin
                        PlaySND(snd_exp,u);
                        _effect_add(vx,vy,map_flydpth[uf]+vy,EID_BExp);
                     end;
        UID_ZEngineer:
                     begin
                        PlaySND(snd_exp,u);
                        _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Exp);
                     end;
            end;
         end;
      end
      else
      case uid of
    UID_ZEngineer  : begin
                        PlaySND(snd_exp,u);
                        _effect_add(vx,vy,map_flydpth[uf]+vy,EID_Exp);
                     end;
    UID_LostSoul   : PlaySND(snd_pexp,u);
    UID_Imp        : if(random(2)=0)
                     then PlaySND(snd_impd1,u)
                     else PlaySND(snd_impd2,u);
    UID_Demon      : PlaySND(snd_demond,u);
    UID_Cacodemon  : PlaySND(snd_cacod,u);
    UID_Baron      : if(buff[ub_advanced]=0)
                     then PlaySND(snd_knightd,u)
                     else PlaySND(snd_barond,u);
    UID_Cyberdemon : PlaySND(snd_cyberd,u);
    UID_Mastermind : PlaySND(snd_mindd,u);
    UID_Pain       : begin
                        PlaySND(snd_pain_d,u);
                        if(OnlySVCode)then
                         if(buff[ub_advanced]>0)then
                         begin
                            _pain_lost(u,x-10+random(20),y-10+random(20));
                            _pain_lost(u,x-10+random(20),y-10+random(20));
                            _pain_lost(u,x-10+random(20),y-10+random(20));
                         end;
                     end;
    UID_Revenant   : PlaySND(snd_rev_d,u);
    UID_Mancubus   : PlaySND(snd_man_d,u);
    UID_Arachnotron: PlaySND(snd_ar_d,u);
    UID_ArchVile   : PlaySND(snd_arch_d,u);
    UID_ZFormer,
    UID_ZSergant,
    UID_ZCommando,
    UID_ZBomber,
    UID_ZMajor,
    UID_ZBFG       : case random(3) of
                     0 : PlaySND(snd_z_d1,u);
                     1 : PlaySND(snd_z_d2,u);
                     2 : PlaySND(snd_z_d3,u);
                     end;
    UID_Engineer,
    UID_Medic,
    UID_Sergant,
    UID_Commando,
    UID_Bomber,
    UID_Major,
    UID_BFG
                 : if(random(2)=1)
                   then PlaySND(snd_ud1,u)
                   else PlaySND(snd_ud2,u);
      end;
   end;
end;

procedure _orders(x,y:integer;i:byte);
begin
   if(ordx[i]=0)then
   begin
      ordx[i]:=x;
      ordy[i]:=y;
   end
   else
    //if(dist2(x,y,ordx[i],ordy[i])<base_ir)then
    begin
       ordx[i]:=(ordx[i]+x) div 2;
       ordy[i]:=(ordy[i]+y) div 2;
    end;
   inc(ordn[i],1);
end;

procedure _unit_uidata(u:integer);
begin
   with _units[u] do
   with _players[player] do
    if(player=HPlayer)and(G_Paused=0)then
    begin
       if(order<10)then
       begin
          _orders(x,y,order);
          ui_orderu[order,isbuild]:=ui_orderu[order,isbuild]+[ucl];
       end;

       if(speed>0)and(uid in whocanattack)then _orders(x,y,10);

       if(isbuild)then
       begin
          if(sel)then
           if(uid in whocanmp)then _sl_add(uo_x-spr_mp[race].hw, uo_y-spr_mp[race].surf^.h,uo_y-spr_mp[race].hh,0,0,0,false,spr_mp[race].surf,255,0,0,0,0,'',0);

          if(bld)then
          begin
             if(ucl=0)and(0<=m_sbuild)and(m_sbuild<=_uts)and(speed=0)then
              if((vid_vx+vid_panel-sr)<vx)and(vx<(vid_vx+vid_mw+sr))and
                ((vid_vy          -sr)<vy)and(vy<(vid_vy+vid_mh+sr))then _addUIBldrs(x,y,sr);

             if(rld>0)then
             begin
                if(ucl=1)then
                begin
                   inc(ui_trntca,1);
                   inc(ui_trntc[utrain],1);
                   if(ui_trnt[utrain]=0)or(ui_trnt[utrain]>rld)then ui_trnt[utrain]:=rld;
                end;

                if(ucl=3)then
                begin
                   inc(ui_upgrc,1);
                   if(upgrade_mfrg[race,utrain])then inc(ui_upgrct[utrain],1);
                   if(ui_upgrl=0)or(ui_upgrl>rld)then ui_upgrl:=rld;
                   if(ui_upgr[utrain]=0)or(ui_upgr[utrain]>rld)then ui_upgr[utrain]:=rld;
                end;
             end;
          end
          else
          begin
             inc(ui_blds[ucl],1);
             inc(ui_bldsc,1);
          end;
       end;

       if(sel)then
       begin
          inc(ui_uselected,1);
          if(bld)then
          begin
             if(speed>0)then inc(ui_uimove,1);
             if(uid in whocanaction)then inc(ui_uiaction,1);
          end;
       end;

       if(speed>0)and(uid in whocanattack)then inc(ui_batlu,1);
    end;
end;

procedure _unit_vis(u:integer;nanim:boolean);
var spr : PTUSprite;
     dp,smy,
     inv,t,ro,
     sh : integer;
     mc,
     rc : cardinal;
     sb : single;
b0,b2,b3: byte;
    b1  : string6;
    rct : boolean;
begin
   with _units[u] do
    if(hits>0)then
    with _players[player] do
     begin
        if(inapc>0)then exit;

        _unit_uidata(u);

        if(_unit_fogrev(u))then
        begin
           _unit_minimap(u);

           if(uid=UID_HKeep)then
            if(buff[ub_clcast]>0)then exit;

           wanim:=false;
           if(g_paused=0)then
            if(_canmove(u))then
             wanim:=(x<>mv_x)or(y<>mv_y)or(x<>vx)or(y<>vy);

           spr:=_unit_spr(@_units[u]);
           sh :=0;
           smy:=vy;

           if(shadow>0)then
           begin
              sh:=shadow;
              if(uid=UID_UCommandCenter)then
              begin
                 if(buff[ub_advanced]=0)
                 then dec(smy,buff[ub_clcast])
                 else inc(smy,buff[ub_clcast]);
              end;
           end;

           if ((vid_vx+vid_panel-spr^.hw)<vx )and(vx <(vid_vx+vid_mw+spr^.hw))and
              ((vid_vy-sh       -spr^.hh)<smy)and(smy<(vid_vy+vid_mh+spr^.hh)) then
           begin
              dp :=0;
              inv:=255;
              rc :=0;
              sb :=0;
              mc :=0;
              b0 :=0;
              b1 :='';
              b2 :=0;
              b3 :=0;
              rct:=false;
              rc :=plcolor[player];
              ro :=0;

              if(isbuild)then
              begin
                 if(sel)then
                  case uid of
                  UID_UTurret,
                  UID_UPTurret,
                  UID_URTurret,
                  UID_HTower,
                  UID_HTotem   : ro:=ar;
                  UID_Mine,
                  UID_HEye     : ro:=sr;
                  UID_HSymbol  : if(upgr[upgr_b478tel]>0)then ro:=sr;
                  else
                  if(ucl=0)and(speed=0)then ro:=sr;
                  end;
                 if(0<=m_sbuild)and(m_sbuild<=_uts)then ro:=r;
              end;

              if(wanim)then
              case uid of
                UID_Arachnotron :
                      begin
                         inc(foot,1);
                         foot:=foot mod 28;
                         if(foot=0)then PlaySND(snd_ar_f,u);
                      end;
                UID_Cyberdemon :
                      begin
                         inc(foot,1);
                         foot:=foot mod 30;
                         if(foot=0)then PlaySND(snd_cyberf,u);
                      end;
                UID_Mastermind :
                      begin
                         inc(foot,1);
                         foot:=foot mod 22;
                         if(foot=0)then PlaySND(snd_mindf,u);
                      end;
              end;

              if((sel)and(player=HPlayer))
              or(k_alt>1)
              or((ui_umark_u=u)and(vid_rtui>6))then
              begin
                 rct:=true;
                 if(buff[ub_advanced ]>0)then b1:=b1+adv_char;
                 if(buff[ub_detect   ]>0)then b1:=b1+hp_detect;
                 if(player=HPlayer)then
                 begin
                    if(order>0)then b0:=order;
                    if(apcm>0)then
                    begin
                       b2:=apcm;
                       b3:=apcc;
                    end;
                 end;
              end;
              if(hits<mhits)or(rct)then sb:=hits/mhits;

              if(buff[ub_invis    ]>0 )then inv:=128;
              if(buff[ub_invuln   ]>10)then mc:=c_awhite;

              if(g_mode in [gm_inv])and(player=0)then mc:=c_ablack;

              dp:=_udpth(u);

              if(isbuild)then
               if(bld)then
               begin
                  if(uid in [UID_UTurret,UID_UPTurret,UID_URTurret])then
                  begin
                     if(rld=0)then begin if(nanim=false)then inc(dir,anims);dir:=dir mod 360;end;
                     t:=abs( ((dir+23) mod 360) div 45 );
                     if(uid<>UID_URTurret)and(rld>rld_a)then t:=t+8;
                     case uid of
                     UID_UTurret,
                     UID_UPTurret: _sl_add(vx-spr_tur [t].hw, smy-spr^.hh,dp,0,0,0,false,spr_tur [t].surf,inv,0,0,0,0,'',0);
                     UID_URTurret: with spr_rtur[t] do _sl_add(vx-hw, smy-spr^.hh-hh,dp,0,0,0,false,surf,inv,0,0,0,0,'',0);
                     end;
                  end;
                  if(uid=UID_UCommandCenter)and(upgr[upgr_ucomatt]>0)then
                  begin
                     if(uf=uf_ground)
                     then t:=0
                     else
                       if(nanim=false)then
                       begin
                          inc(anim,1);
                          if(anim>=vid_hfps)then anim:=-vid_hfps+1+vid_hhhfps;
                          t:=anim div vid_hhhfps;
                       end;
                     t:=mm3(0,abs(t),3);

                     with spr_eff_bfg[t] do _sl_add(vx+4-hw, smy-hh+8,dp,0,0,0,false,surf,mm3(0,255-trunc(255*(rld/rld_r)),255),0,0,0,0,'',0);
                  end;
                  if(player=HPlayer)then
                  begin
                     if(rld>0)then
                     begin
                        if(utrain<_uts)then
                        begin
                           if(uid=UID_HMilitaryUnit )
                           or(uid=UID_HGate         )then _sl_add(vx-24,smy-24,dp,0,c_gray,0,true,spr_b_u[r_hell,utrain],255,0,(rld div vid_fps)+1,0,0,'',0);
                           if(uid=UID_UMilitaryUnit )then _sl_add(vx-24,smy-24,dp,0,c_gray,0,true,spr_b_u[r_uac ,utrain],255,0,(rld div vid_fps)+1,0,0,'',0);
                        end;
                        if(utrain<=MaxUpgrs)then
                        begin
                           if(uid=UID_HPools        )then _sl_add(vx-24,smy-24,dp,0,c_red,0,true,spr_b_up[r_hell,utrain],255,0,(rld div vid_fps)+1,0,0,'',0);
                           if(uid=UID_UWeaponFactory)then _sl_add(vx-24,smy-24,dp,0,c_red,0,true,spr_b_up[r_uac ,utrain],255,0,(rld div vid_fps)+1,0,0,'',0);
                        end;
                     end;
                  end;
               end
               else
                if(race=r_hell)then
                begin
                   inv:=trunc(255*hits/mhits);
                   if(r<41)
                   then _sl_add(vx-spr_db_h1.hw,smy-spr_db_h1.hh+5 ,-5,0,0,0,false,spr_db_h1.surf,255-inv,0,0,0,0,'',0)
                   else _sl_add(vx-spr_db_h0.hw,smy-spr_db_h0.hh+10,-5,0,0,0,false,spr_db_h0.surf,255-inv,0,0,0,0,'',0);
                   if(buff[ub_invis]>0)then inv:=inv shr 1;
                   dec(inv,inv shr 2);
                end;

               if(buff[ub_toxin]>0)then
                if(mech)
                then _sl_add(vx-spr_gear .hw, smy-spr^.hh-spr_gear .surf^.h-7,dp,0,0,0,false,spr_gear .surf,255,0,0,0,0,'',0)
                else _sl_add(vx-spr_toxin.hw, smy-spr^.hh-spr_toxin.surf^.h-7,dp,0,0,0,false,spr_toxin.surf,255,0,0,0,0,'',0);
               if(buff[ub_gear ]>0)then _sl_add(vx-spr_gear .hw, smy-spr^.hh-spr_gear .surf^.h-7,dp,0,0,0,false,spr_gear .surf,255,0,0,0,0,'',0);

              _sl_add(vx-spr^.hw, smy-spr^.hh,dp,sh,rc,mc,rct,spr^.surf,inv,sb,b0,b2,b3,b1,ro);
           end;
        end;
     end;
end;

{$ENDIF}

function _unit_OnDecorCheck(ux,uy:integer):boolean;
const dr = 64;
var i,dx,dy,ud,dp:integer;
begin
   dx:=ux div dcw;if(dx<0)then dx:=0;if(dx>dcn)then dx:=dcn;
   dy:=uy div dcw;if(dy<0)then dy:=0;if(dy>dcn)then dy:=dcn;
   _unit_OnDecorCheck:=false;
   dp:=0;

   with map_dcell[dx,dy] do
    for i:=1 to n do
     with map_dds[l[i-1]] do
      if(r>0)and(t>0)then
      begin
         ud:=(dist2(x,y,ux,uy)-r);
         if(ud<0)then inc(dp,1);
         inc(ud,dr);
         if(ud<0)or(dp>1)then
         begin
            _unit_OnDecorCheck:=true;
            exit;
         end;
      end;
end;

procedure _unit_UACUpgr(u:integer;tu:PTUnit);
begin
   with _units[u] do
   begin
      buff[ub_gear    ]:=gear_time[mech];
      buff[ub_advanced]:=_bufinf;
      with _players[tu^.player] do
      begin
         if(mech)
         then tu^.rld:=mech_adv_rel[(g_addon=false)or(upgr[upgr_6bld2]>0)]
         else tu^.rld:= uac_adv_rel[(g_addon=false)or(upgr[upgr_6bld2]>0)];
      end;
      {$IFDEF _FULLGAME}
      PlaySND(snd_uupgr,u);
      {$ENDIF}
   end;
end;

procedure _unit_dec_Kcntrs(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin
      if(sel)then
      begin
         dec(u_s [isbuild,ucl],1);
         dec(u_cs[isbuild],1);
      end;
      sel:=false;

      if(isbuild)then
       if(bld=false)
       then dec(cenerg,_ulst[cl2uid[race,true,ucl]].renerg)
       else
       begin
          _unit_ctraining(u);
          _unit_cupgrade(u);

          dec(u_eb[isbuild,ucl],1);
          dec(uid_b[uid],1);
          dec(menerg,generg);
          if(ucl=0)then dec(bldrs,1);
       end;
      if(ubx[ucl]=u)then ubx[ucl]:=0;
   end;
end;

procedure _unit_dec_Rcntrs(u:integer);
begin
   with _units[u] do
    with _players[player] do
    begin
       dec(army,1);
       dec(u_e[isbuild,ucl],1);
       dec(u_c[isbuild],1);
       dec(uid_e[uid],1);
    end;
end;

procedure _unit_remove(u:integer);
begin
   with _units[u] do
    with _players[player] do
    begin
       _unit_dec_Rcntrs(u);

       if(G_WTeam=255)then
        if(player<>0)or not(g_mode in [gm_inv])then
         if(army=0){$IFDEF _FULLGAME}and(menu_s2<>ms2_camp){$ENDIF}
         and(state>ps_none)then net_chat_add(name+str_player_def,player,255);
    end;
end;

procedure _unit_death(u:integer);
var
    tu,
    uu  : PTUnit;
    uc  : integer;
begin
   with _units[u] do
    with _players[player] do
     if(hits>dead_hits)then
     begin
        _unit_counters(u);

        if(_uclord=_uclord_c)then
        begin
           uu:=@_units[u];
           for uc:=1 to MaxUnits do
            if(uc<>u)then
            begin
               tu:=@_units[uc];
               if(tu^.hits>dead_hits)then _udetect(uu,tu,dist2(x,y,tu^.x,tu^.y));
            end;
        end;

        if(buff[ub_resur]=0)then
        begin
           if(onlySVCode){or(hits>-100)}then dec(hits,1);
           if(_uclord=_uclord_c)and(fsr>1)then dec(fsr,1);

           if(onlySVCode)then
           begin
              case uid of
              UID_Cacodemon: if(hits>-shadow)then
                             begin
                                inc(y,1);
                                inc(vy,1);
                                _unit_correctcoords(u);
                                {$IFDEF _FULLGAME}
                                _unit_mmcoords(u);
                                _unit_sfog(u);
                                {$ENDIF}
                             end;
              end;

              if(hits<=dead_hits)then
              begin
                 _unit_remove(u);
                 exit;
              end;
           end
           else _unit_movevis(u);
        end
        else
         if(OnlySVCode)then
         begin
            if(hits<-80)then hits:=-80;
            inc(hits,1);
            case uid of
            UID_Cacodemon: if(hits>-shadow)then begin dec(vy,1);dec(y,1);end;
            end;
            if(hits>=0)then
            begin
               uo_x:=x;
               uo_y:=y;
               dir :=270;
               hits:=mhits;
               buff[ub_resur]:=0;
               buff[ub_born ]:=vid_fps;
               {$IFDEF _FULLGAME}
               _unit_fsrclc(@_units[u]);
               if(player=HPlayer)then _unit_createsound(uid);
               {$ENDIF}
            end;
         end;
     end;
end;


procedure _check_missiles(u:integer);
var i:integer;
begin
   for i:=1 to MaxUnits do
    with _missiles[i] do
     if(vst>0)and(tar=u)then tar:=0;
end;

procedure _unit_kill(u:integer;nodead,deff:boolean);
var i :integer;
    tu:PTunit;
begin
   if(u>0)then
  with _units[u] do
  with _players[player] do
  begin
     if(nodead=false)then
     begin
        if(uid in [UID_Major,UID_ZMajor])and(uf>uf_ground)
        then deff:=true
        else
          if not(uid in gavno)
          then deff:=false;
        if(mech)or(uid in [UID_LostSoul,UID_Pain,UID_ZEngineer])then deff:=true;

        buff[ub_pain]:=vid_fps;
        {$IFDEF _FULLGAME}
        _unit_deff(u,deff);
        {$ENDIF}
     end;

     _unit_dec_Kcntrs(u);

     if(isbuild)then
      if not(uid in [UID_HEye,UID_Mine])then
      begin
         inc(bld_r,vid_3fps);
         if(bld_r>bld_r_max)then bld_r:=bld_r_max;
      end;

     x     :=vx;
     y     :=vy;
     uo_x  :=x;
     uo_y  :=y;
     mv_x  :=x;
     mv_y  :=y;
     tar1  :=0;
     tar1d :=32000;
     rld   :=0;
     uo_tar:=0;

     for i:=1 to MaxUnits do
     if(i<>u)then
     begin
        tu:=@_units[i];
        if(tu^.hits>0)then
        begin
           if(tu^.uo_tar=u)then tu^.uo_tar:=0;
           if(apcc>0)then
            if(tu^.inapc=u)then
            begin
               if(uid in [UID_FAPC])or(inapc>0)
               then _unit_kill(i,true,false)
               else
               begin
                  tu^.inapc:=0;
                  dec(apcc,tu^.apcs);
                  tu^.x:=tu^.x-15+random(30);
                  tu^.y:=tu^.y-15+random(30);
                  tu^.uo_x:=tu^.x;
                  tu^.uo_y:=tu^.y;
                  if(tu^.hits>apc_exp_damage)then
                  begin
                     dec(tu^.hits,apc_exp_damage);
                     tu^.buff[ub_invuln]:=10;
                  end
                  else _unit_kill(i,true,false);
               end;
            end;
        end;
     end;
     _check_missiles(u);

     if(nodead)then
     begin
        hits:=ndead_hits;
        _unit_remove(u);
     end
     else
       if(deff)
       then hits:=idead_hits
       else hits:=0;
  end;
end;

procedure _unit_damage(u,dam:integer;p,pl:byte);
const build_arm_f = 16;
       unit_arm_f = 24;
var arm:integer;
begin
  if(onlySVCode)then
   with _units[u] do
   begin
      if(buff[ub_invuln]>0)or(hits<0)or(dam<0)then exit;

      arm:=0;

      with _players[player] do
      begin
         if(isbuild)then
         begin
            if(bld)then
            begin
               arm:=upgr[upgr_build];
               if(uid in [UID_UTurret,UID_UPTurret,UID_URTurret])then
                if(g_addon=false)
                then inc(arm,1)
                else
                 if(upgr[upgr_turarm]>0)then inc(arm,upgr[upgr_turarm]);

               if(dam>=build_arm_f)
               then inc(arm,(dam div build_arm_f)*arm);

               inc(arm,5);
            end;
         end
         else
           if(mech)then
           begin
              if(race=r_uac)then
              begin
                 arm:=upgr[upgr_mecharm];

                 if(dam>=unit_arm_f)
                 then inc(arm,(dam div unit_arm_f)*arm);

                 inc(arm,3);
              end;
           end
           else
           begin
              arm:=upgr[upgr_armor];

              if(dam>=unit_arm_f)
              then inc(arm,(dam div unit_arm_f)*arm);

              case uid of
              UID_Demon,
              UID_Cacodemon : inc(arm,2);
              UID_Baron,
              UID_Archvile  : inc(arm,3);
              else
                 if(uid in type_massive)then inc(arm,3);
              end;
           end;

         if(uid=UID_LostSoul)and(g_addon)then
         begin
            arm:=0;
            inc(p,4);
         end;

         if(buff[ub_advanced]>0)then
         begin
            case uid of
              UID_Baron : inc(arm,dam div 2);
            else
            end;
         end;

         if(uid in [UID_HEye,UID_Mine])then
         begin
            dam:=hits;
            arm:=0;
         end;

         if(g_mode in [gm_inv])and(player=0)then dam:=dam div 2;
      end;

      dec(dam,arm);

      if(dam<=0)then
       if(random(abs(dam)+1)=0)
       then dam:=1
       else dam:=0;

      if(hits<=dam)
      then _unit_kill(u,false,(hits-dam)<gavno_dth_h)
      else
      begin
         dec(hits,dam);

         if(mech)then
         begin
            buff[ub_pain]:=vid_2fps;
         end
         else
           if(painc>0)and(buff[ub_pain]=0)then
           begin
              if(uid=UID_Mancubus)and(buff[ub_advanced]>0)then exit;

              if(p>pains)
              then pains:=0
              else dec(pains,p);

              if(pains=0)then
              begin
                 pains:=painc;

                 buff[ub_pain   ]:=pain_time;
                 buff[ub_stopafa]:=pain_time;

                 if(uid in [UID_Mancubus,UID_ArchVile,UID_ZBFG])then rld:=0;

                 with _players[player] do
                  if(race=r_hell)then
                   if(upgr[upgr_pains]>0)then
                    if(uid=UID_LostSoul)
                    then inc(pains,upgr[upgr_pains])
                    else inc(pains,upgr[upgr_pains]*4);
                 {$IFDEF _FULLGAME}
                 _unit_painsnd(u);
                 {$ENDIF}
              end;
           end;
      end;
   end;
end;

{$Include _missiles.pas}

procedure _unit_URocketL(u:integer);
var i:byte;
begin
   with _units[u] do
    if(bld)then
     with _players[player] do
      if(rld=0)and(race=r_uac)then
       if(upgr[upgr_blizz]>0)and(rld=0)then
       begin
          for i:=0 to MaxPlayers do _addtoint(@vsnt[i],vid_2fps);
          _miss_add(uo_x,uo_y,vx,vy,0,MID_Blizzard,player,uf_soaring,false);
          rld:=urocketl_rld;
          dec(upgr[upgr_blizz],1);
          {$IFDEF _FULLGAME}
          _uac_rocketl_eff(u);
          {$ENDIF}
       end;
end;

procedure _unit_bteleport(u:integer);
begin
   with _units[u] do
    with _players[player] do
     if(bld)then
      if(upgr[upgr_mainm]>0)and(buff[ub_clcast]=0)then
       if(_unit_grbcol(uo_x,uo_y,r,255,(upgr[upgr_mainonr]<=0)and(G_addon))=0)then
       begin
          dec(upgr[upgr_mainm],1);
          {$IFDEF _FULLGAME}
          if(_uvision(_players[HPlayer].team,@_units[u],true))then
           if(_nhp(x,y) or _nhp(uo_x,uo_y))then PlaySND(snd_cubes,0);
          _effect_add(x,y,0,EID_HKT_h);
          {$ENDIF}
          buff[ub_clcast ]:=vid_fps;
          buff[ub_teleeff]:=vid_fps;
          x :=uo_x;
          y :=uo_y;
          _unit_correctcoords(u);
          vx:=x;
          vy:=y;
          {$IFDEF _FULLGAME}
          _effect_add(x,y,0,EID_HKT_s);
          _unit_sfog(u);
          _unit_mmcoords(u);
          {$ENDIF}
       end;
end;

procedure _unit_b247teleport(u:integer);
begin
   with _units[u] do
    with _players[player] do
     if(bld)then
      if(upgr[upgr_b478tel]>0)and(buff[ub_clcast]<=0)then
       if(dist2(x,y,uo_x,uo_y)<sr)and(_unit_grbcol(uo_x,uo_y,r,255,true)=0)then
       begin
          dec(upgr[upgr_b478tel],1);
          _unit_teleport(u,uo_x,uo_y);
          buff[ub_clcast ]:=vid_fps;
          buff[ub_teleeff]:=vid_fps;
       end;
end;

{procedure _unit_morph(u:integer;nuid:byte;ubld:boolean);
begin
   with _units[u] do
    with _players[player] do
    begin
       _unit_dec_Kcntrs(u);
       _unit_dec_Rcntrs(u);

       uid :=nuid;
       _unit_sclass(@_units[u]);

       _unit_inc_cntrs(u,ubld);
    end;
end; }

procedure _pain_action_code(u:integer);
begin
   with _units[u] do
   if(_canmove(u))and(rld=0)then
   begin
      buff[ub_cast]:=vid_hfps;
      rld:=rld_r;
      _pain_action(u);
   end;
end;

procedure _unit_action(u:integer);
begin
   with _units[u] do
   if(bld)then
    with _players[player] do
     case uid of
UID_UCommandCenter:
                if(buff[ub_clcast]=0)then
                 if(upgr[upgr_mainm]>0)then
                 begin
                    if(buff[ub_advanced]=0)then
                    begin
                       buff[ub_advanced]:= _bufinf;
                       speed            := 4;
                       uf               := uf_fly;
                       buff[ub_clcast]  := uaccc_fly;
                       dec(y,buff[ub_clcast]);
                       {$IFDEF _FULLGAME}
                       PlaySND(snd_ccup,u);
                       {$ENDIF}
                       uo_x:=x;
                       uo_y:=y;
                    end
                    else
                      if(_unit_grbcol(x,y+uaccc_fly,r,255,upgr[upgr_mainonr]=0)=0)then
                      begin
                         buff[ub_advanced]:= 0;
                         speed            := 0;
                         uf               := uf_ground;
                         buff[ub_clcast]  := uaccc_fly;
                         inc(y,buff[ub_clcast]);
                         vy:=y;
                         {$IFDEF _FULLGAME}
                         PlaySND(snd_inapc,u);
                         {$ENDIF}
                         uo_x:=x;
                         uo_y:=y;
                      end;
                 end;
UID_Engineer :  if(army<MaxPlayerUnits)and(upgr[upgr_mines]>0)and(menerg>0)and(inapc=0)and(buff[ub_cast]=0)then
                begin
                   _unit_add(vx,vy,UID_Mine,player,true);
                   buff[ub_cast]:=vid_hfps;
                end;
UID_APC,
UID_FAPC     :  if(apcc>0)then uo_id:=ua_unload;

UID_Pain     :  _pain_action_code(u);
UID_LostSoul :  if(upgr[upgr_vision]>0)then
                begin
                   {$IFDEF _FULLGAME}
                   _effect_add(vx,vy,vy+1,UID_LostSoul);
                   if(player=HPlayer)then PlaySND(snd_hellbar,0);
                   {$ENDIF}
                   //_unit_morph(u,UID_HEye,true);
                   _unit_kill(u,true,true);
                   _unit_add(x,y,UID_HEye,player,true);
                   order:=0;
                end;
UID_Major,
UID_ZMajor   : if(buff[ub_advanced]>0)and(buff[ub_clcast]=0)then
               begin
                  if(uf>uf_ground)then
                   if(_unit_OnDecorCheck(x,y))then exit;

                  if(buff[ub_cast]>0)
                  then buff[ub_cast]:=0
                  else buff[ub_cast]:=_bufinf;

                  buff[ub_clcast]:=vid_fps;

                  {$IFDEF _FULLGAME}
                  if(buff[ub_cast]>0)
                  then PlaySND(snd_jetpon,u)
                  else PlaySND(snd_jetpoff,u);
                  {$ENDIF}
               end;
     end;
end;

procedure _unit_push(u,i,ud:integer);
var ix,iy,t:integer;
    tu:PTUnit;
begin
   with _units[u] do
   begin
      tu:=@_units[i];

      t:=ud;
      if(tu^.speed=0)
      then dec(ud,tu^.r)
      else dec(ud,r+tu^.r);

      if(ud<0)then
      begin
         if(t<=0)then t:=1;

         ix:=trunc(ud*(tu^.x-x)/t)+1-random(2);
         iy:=trunc(ud*(tu^.y-y)/t)+1-random(2);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(u);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(u);
         _unit_sfog(u);
         {$ENDIF}

         dir:=(360+dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 )) mod 360;

         if(tu^.x=tu^.uo_x)and(tu^.y=tu^.uo_y)and(uo_tar=0)then
         begin
            ud:=dist2(uo_x,uo_y,tu^.x,tu^.y)-r-tu^.r;
            if(ud<=0)then
            begin
               uo_x:=x;
               uo_y:=y;
            end;
         end;
      end;
   end;
end;

procedure _unit_dpush(u,d:integer);
var ix,iy,t,ud:integer;
    td:PTDoodad;
begin
   with _Units[u] do
   begin
      td:=@map_dds[d];

      ud:=dist(x,y,td^.x,td^.y);
      t :=ud;
      dec(ud,r+td^.r-8);

      if(ud<0)then
      begin
         if(t<=0)then t:=1;
         ix:=trunc(ud*(td^.x-x)/t)+1-random(2);
         iy:=trunc(ud*(td^.y-y)/t)+1-random(2);

         inc(x,ix);
         inc(y,iy);

         vstp:=UnitStepNum;

         _unit_correctcoords(u);
         {$IFDEF _FULLGAME}
         _unit_mmcoords(u);
         _unit_sfog(u);
         {$ENDIF}

         if(rld=0)then dir:=(360+dir-(dir_diff(dir,p_dir(vx,vy,x,y)) div 2 )) mod 360;

         t:=dist2(uo_x,uo_y,td^.x,td^.y)-r-td^.r;
         if(t<=0)then
         begin
            uo_x:=x;
            uo_y:=y;
         end;
      end;
   end;
end;

procedure _unit_npush(u:integer);
var i,dx,dy:integer;
begin
   dx:=_units[u].x div dcw;if(dx<0)then dx:=0;if(dx>dcn)then dx:=dcn;
   dy:=_units[u].y div dcw;if(dy<0)then dy:=0;if(dy>dcn)then dy:=dcn;

   with map_dcell[dx,dy] do
    for i:=1 to n do
     with map_dds[l[i-1]] do
      if(r>0)and(t>0)then _unit_dpush(u,l[i-1]);
end;

procedure _unit_npush2(u:integer);
begin
   with _units[u] do
    with _players[player] do
     if(speed>0)and(uf=uf_ground)and(solid)then _unit_npush(u);
end;

procedure _unit_move(u:integer);
var mdist,spup:integer;
    tu:PTUnit;
begin
  with(_units[u])do
   if(inapc>0)then
   begin
      tu     :=@_units[inapc];
      fx     := tu^.fx;
      fy     := tu^.fy;
      x      := tu^.x;
      y      := tu^.y;
      mmx    := tu^.mmx;
      mmy    := tu^.mmy;

      if(tu^.uo_id<>uo_id)then
       if(tu^.uo_id<>ua_unload)then
       begin
          uo_id:=tu^.uo_id;
          if(uo_id<>ua_amove)then tar1 :=0;
       end;
      if(tu^.tar1=tu^.uo_tar)then
      begin
         tar1 :=tu^.uo_tar;
         uo_id:=ua_move;
      end;
      {$IFDEF _FULLGAME}
      if(player=HPlayer)then
       if(tu^.sel)then inc(ui_apc[ucl],1);
      {$ENDIF}
   end
   else
   begin
      case uid of
      UID_Major,
      UID_ZMajor:if(_unit_flyup(u,2+(uf*fly_height)))then
                 begin
                   {$IFDEF _FULLGAME}
                   case uid of
                   UID_Major : PlaySND(snd_oof ,u);
                   UID_ZMajor: PlaySND(snd_z_p ,u);
                   end;
                   {$ENDIF}
                end;
      end;

    if(onlySVCode)then
     if(_canmove(u))then
      if(x=vx)and(y=vy)then
       if(x<>mv_x)or(y<>mv_y)then
       begin
           mdist:=dist2(x,y,mv_x,mv_y);
           if(mdist<=speed)then
           begin
              x:=mv_x;
              y:=mv_y;
              dir:=p_dir(vx,vy,x,y);
           end
           else
           begin
              spup:=speed;

              if(uid=UID_UTransport)and(buff[ub_pain]>0)then dec(spup,2);
              with _players[player] do
              begin
                 if(race=r_uac)and(isbuild=false)then
                  case mech of
                  true : if(upgr[upgr_mechspd]>0)then inc(spup,upgr[upgr_mechspd]);
                  false: if(upgr[upgr_mspeed ]>0)then inc(spup,upgr[upgr_mspeed ]);
                  end;
              end;
              if(buff[ub_slooow]>0)then spup:=spup div 2;


              if(mdist>70)
              then mdist:=8+random(25)
              else mdist:=50;

              dir:=dir_turn(dir,p_dir(x,y,mv_x,mv_y),mdist);

              x:=x+round(spup*cos(dir*degtorad));
              y:=y-round(spup*sin(dir*degtorad));
           end;
           _unit_npush2(u);
           _unit_correctcoords(u);
           {$IFDEF _FULLGAME}
           _unit_mmcoords(u);
           _unit_sfog(u);
           {$ENDIF}
        end;
   end;
end;

procedure _unit_attack(u:integer);
var tu1 :PTUnit;
    ux,uy,
    mdam:integer;
function _tuf(uu_uf,tu_uf:byte):byte;
begin
    if(tu_uf>uu_uf)
    then _tuf:=tu_uf
    else
     if(abs(uu_uf-tu_uf)>1)
     then _tuf:=uf_soaring
     else _tuf:=uu_uf;
end;
begin
   with _units[u] do
   begin
      if(tar1<=0)or(tar1>MaxUnits)then exit;

      mdam:=0;
      tu1:=@_units[tar1];

      if(rld=0)then
      begin
         if(melee)then mdam:=_unit_melee_damage(@_units[u],tu1,mdmg);

         case uid of
         UID_LostSoul :
               begin
                  {$IFDEF _FULLGAME}
                  PlaySND(snd_d0,u);
                  {$ENDIF}
                  rld:=rld_r;

                  if(OnlySVCode)then
                  if(buff[ub_advanced]>0)then
                   if(tu1^.uid in marines)then
                   begin
                      uy:=order;
                      ux:=tar1;
                      mdam:=tu1^.hits;

                      _unit_kill(u,true,true);
                      hits:=ndead_hits;

                      case tu1^.uid of
                      UID_Medic    : _unit_add(tu1^.vx,tu1^.vy,UID_ZFormer  ,player,true);
                      UID_Engineer : _unit_add(tu1^.vx,tu1^.vy,UID_ZEngineer,player,true);
                      UID_Sergant  : _unit_add(tu1^.vx,tu1^.vy,UID_ZSergant ,player,true);
                      UID_Commando : _unit_add(tu1^.vx,tu1^.vy,UID_ZCommando,player,true);
                      UID_Bomber   : _unit_add(tu1^.vx,tu1^.vy,UID_ZBomber  ,player,true);
                      UID_Major    : _unit_add(tu1^.vx,tu1^.vy,UID_ZMajor   ,player,true);
                      UID_BFG      : _unit_add(tu1^.vx,tu1^.vy,UID_ZBFG     ,player,true);
                      end;
                      if(_lcu=0)then exit;

                      if(tu1^.hits<0)then
                      begin
                         _lcup^.hits:=-100;
                         _lcup^.buff[ub_resur]:=254;
                      end
                      else
                        if(mdam>0)then
                        begin
                           _lcup^.hits:=mdam;
                           {$IFDEF _FULLGAME}
                           if(player=HPlayer)then _unit_createsound(_lcup^.uid);
                           {$ENDIF}
                        end;

                      _lcup^.buff[ub_advanced]:=tu1^.buff[ub_advanced];
                      _lcup^.dir:=tu1^.dir;
                      _lcup^.order:=uy;

                      _unit_kill(ux,true,true);
                      _units[ux].hits:=ndead_hits;
                      exit;
                   end
                   else
                     if(tu1^.uid=UID_UMilitaryUnit)and(tu1^.hits<1000)and(tu1^.bld)then
                     begin
                        ux:=tar1;
                        mdam:=tu1^.hits;
                        _unit_kill(u,true,true);
                        hits:=ndead_hits;

                        _lcu:=0;
                        _unit_add(tu1^.vx,tu1^.vy,UID_HMilitaryUnit  ,player,true);
                        {$IFDEF _FULLGAME}
                        _effect_add(tu1^.vx,tu1^.vy,tu1^.vy+1,UID_HMilitaryUnit);
                        PlaySND(snd_hellbar,u);
                        {$ENDIF}
                        _lcup^.hits:=mdam;

                        _unit_kill(ux,true,true);
                        _units[ux].hits:=ndead_hits;
                        exit;
                     end;

                  _unit_damage(tar1,mdam,2,player);
               end;
         UID_Imp      :
               begin
                  if(melee)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hmelee,u);{$ENDIF}
                     _unit_damage(tar1,mdam,1,player);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hshoot,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Imp,player,_tuf(uf,tu1^.uf),false);
                  end;
                  rld:=rld_r;
               end;
         UID_Demon    :
               begin
                  _unit_damage(tar1,mdam,1,player);
                  {$IFDEF _FULLGAME}PlaySND(snd_demona,u);{$ENDIF}
                  rld:=rld_r;
               end;
         UID_Cacodemon:
               begin
                  if(melee)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hmelee,u);{$ENDIF}
                     _unit_damage(tar1,mdam,1,player);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hshoot,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Cacodemon,player,_tuf(uf,tu1^.uf),false);
                  end;
                  rld:=rld_r;
               end;
         UID_Baron:
               begin
                  if(melee)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hmelee,u);{$ENDIF}
                     _unit_damage(tar1,mdam,1,player);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_hshoot,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Baron,player,_tuf(uf,tu1^.uf),false);
                  end;
                  rld:=rld_r;
               end;
         UID_Cyberdemon:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_launch,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_HRocket,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_Mastermind:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bulletx2,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_Pain      :
               begin
                  rld:=rld_r;
                  _pain_action(u);
               end;
         UID_Revenant  :
               begin
                  if(melee)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_rev_m,u);{$ENDIF}
                     _unit_damage(tar1,mdam,1,player);
                     rld:=rld_r shr 1;
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_rev_a,u);{$ENDIF}

                     with _players[player] do
                      if(upgr[upgr_revmis]>0)
                      then ux:=MID_RevenantS
                      else ux:=MID_Revenant;

                     _miss_add(tu1^.x,tu1^.y,vx,vy-16,tar1,ux,player,_tuf(uf,tu1^.uf),false);

                     rld:=rld_r;
                  end;
               end;
         UID_Mancubus :
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_man_a,u);{$ENDIF}
                  rld:=rld_r;
               end;
         UID_Arachnotron:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_plasmas,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_YPlasma,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
                  _addtoint(@tu1^.vsnt[_players[player].team],vid_fps);
               end;
         UID_ArchVile :
               begin
                  if(melee)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_meat,u);{$ENDIF}
                     buff[ub_cast]:=vid_fps;
                     rld:=vid_fps;
                     if(OnlySVCode)then
                     begin
                        tu1^.buff[ub_resur]:=_bufinf;
                        tar1 :=0;
                        tar1d:=32000;
                     end;
                     exit;
                  end
                  else
                   if(buff[ub_cast]=0)then
                   begin
                      rld:=rld_r;
                      {$IFDEF _FULLGAME}
                      PlaySND(snd_arch_at,u);
                      if(_nhp(tu1^.x,tu1^.y))then
                      begin
                         PlaySND(snd_arch_f,tar1);
                         _effect_add(tu1^.x,tu1^.y,tu1^.vy+map_flydpth[tu1^.uf]+1,EID_ArchFire);
                      end;
                      {$ENDIF}
                   end;
               end;
         UID_Engineer:
               begin
                  if(melee)then
                  begin
                     if(tu1^.buff[ub_pain]=0)then
                     begin
                        {$IFDEF _FULLGAME}
                        PlaySND(snd_cast2,u);
                        if(inapc=0)then
                        begin
                           ux:=tu1^.r shr 1;
                           uy:=tu1^.r;
                           _effect_add(tu1^.x-ux+random(uy),tu1^.y-ux+random(uy),tu1^.y+50,MID_BPlasma);
                        end;
                        {$ENDIF}
                        if(inapc=tar1)
                        then rld:=rld_r+rld_r
                        else rld:=rld_r;
                        if(onlySVCode)then
                        begin
                           inc(tu1^.hits,mdmg);
                           if(tu1^.hits>tu1^.mhits)then tu1^.hits:=tu1^.mhits;
                        end;
                     end;
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_pistol,u);{$ENDIF}
                     if(buff[ub_advanced]=0)
                     then _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet ,player,_tuf(uf,tu1^.uf),false)
                     else _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_MBullet,player,_tuf(uf,tu1^.uf),false);
                     rld:=rld_r;
                  end;
               end;
         UID_Medic :
               begin
                  if(melee)then
                  begin
                     if(tu1^.buff[ub_pain]=0)then
                     begin
                        {$IFDEF _FULLGAME}
                        PlaySND(snd_cast,u);
                        ux:=tu1^.r shr 1;
                        uy:=tu1^.r;
                        _effect_add(tu1^.x-ux+random(uy),tu1^.y-ux+random(uy),tu1^.y+50,MID_YPlasma);
                        {$ENDIF}
                        rld:=rld_r;
                        if(onlySVCode)then
                        begin
                           inc(tu1^.hits,mdmg);
                           if(tu1^.hits>tu1^.mhits)then tu1^.hits:=tu1^.mhits;
                           if not(tu1^.uid in marines)then tu1^.buff[ub_pain]:=vid_hfps;
                        end;
                     end;
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_pistol,u);{$ENDIF}
                     if(buff[ub_advanced]=0)
                     then _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet ,player,_tuf(uf,tu1^.uf),false)
                     else _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_TBullet,player,_tuf(uf,tu1^.uf),false);
                     rld:=rld_r;
                  end;
               end;
         UID_ZFormer:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_pistol,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;

         UID_ZSergant,
         UID_Sergant:
               begin
                  rld:=rld_r;
                  if(buff[ub_advanced]>0)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_ssg,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_SSShot,player,_tuf(uf,tu1^.uf),false);
                     inc(rld,10);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_SShot ,player,_tuf(uf,tu1^.uf),false);
                  end;
               end;
         UID_ZCommando:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_Commando:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_pistol,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_Bomber,
         UID_ZBomber:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_launch,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy-6,tar1,MID_Granade,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_Major,
         UID_ZMajor:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_plasmas,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_BPlasma,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_BFG,
         UID_ZBFG:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_bfgs,u);{$ENDIF}
                  rld:=rld_r;
               end;
         UID_APC,
         UID_FAPC :
               with _players[player] do
               if(upgr[upgr_plsmt]>0)then
               begin
                  if(upgr[upgr_plsmt]=1)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_pistol,u); {$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet  ,player,_tuf(uf,tu1^.uf),false);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u); {$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bulletx2,player,_tuf(uf,tu1^.uf),false);
                  end;
                  rld:=rld_r;
               end
               else exit;
         UID_Terminator:
               begin
                  if(buff[ub_advanced]>0)then
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bulletx2,player,_tuf(uf,tu1^.uf),false);
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_pistol,u);{$ENDIF}
                     _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bullet  ,player,_tuf(uf,tu1^.uf),false);
                  end;
                  rld:=rld_r;
               end;
         UID_Tank:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_exp,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Tank,player,_tuf(uf,tu1^.uf),true);
                  rld:=rld_r;
               end;
         UID_Flyer:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_fly_a,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Flyer,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;

         UID_ZEngineer:
               begin
                  _miss_add(vx,vy,vx,vy,0,MID_Mine,player,0,true);
                  if(OnlySVCode)then _unit_kill(u,false,true);
               end;
         UID_Mine:
               begin

                  rld:=rld_r;
               end;
         UID_HTower:
               begin
                  if(tu1^.uid=UID_Revenant)then
                  begin
                     _miss_add(tu1^.x,tu1^.y,vx,vy-26,tar1,MID_Cacodemon,player,_tuf(uf,tu1^.uf),false);
                     {$IFDEF _FULLGAME}PlaySND(snd_hshoot,u);{$ENDIF}
                  end
                  else
                  begin
                     {$IFDEF _FULLGAME}PlaySND(snd_rev_a,u); {$ENDIF}
                     with _players[player] do
                      if(upgr[upgr_revmis]>0)or(G_Addon=false)
                      then ux:=MID_RevenantS
                      else ux:=MID_Revenant;
                     _miss_add(tu1^.x,tu1^.y,vx,vy-26,tar1,ux,player,_tuf(uf,tu1^.uf),false);
                  end;
                  {$IFDEF _FULLGAME}_effect_add(vx,vy-26,vy+1,MID_Revenant);{$ENDIF}
                  rld:=rld_r;
               end;
         UID_HTotem:
               begin
                  rld:=rld_r;
                  {$IFDEF _FULLGAME}
                  if(_nhp(tu1^.x,tu1^.y))then
                  begin
                     PlaySND(snd_arch_f,tar1);
                     _effect_add(tu1^.x,tu1^.y,tu1^.vy+map_flydpth[tu1^.uf]+1,EID_ArchFire);
                  end;
                  {$ENDIF}
               end;
         UID_UTurret:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_shotgun,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_Bulletx2,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_UPTurret:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_plasmas,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy-15,tar1,MID_BPlasma,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_URTurret:
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_launch,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy-20,tar1,MID_HRocket,player,_tuf(uf,tu1^.uf),false);
                  rld:=rld_r;
               end;
         UID_UCommandCenter :
               with _players[player] do
               if(uf>uf_ground)and(upgr[upgr_ucomatt]>0)and(race=r_uac)then
               begin
                  {$IFDEF _FULLGAME}PlaySND(snd_pexp,u);{$ENDIF}
                  _miss_add(tu1^.x,tu1^.y,vx,vy+10,tar1,MID_BFG,player,uf_ground,false);
                  rld:=rld_r;
               end
               else exit;
         end;
      end;

      if(rld>0)then
       case uid of
        UID_Mine: if(rld=vid_fps)then
                  begin
                      _miss_add(vx,vy,vx,vy,0,MID_MineShock,player,uf_soaring,true);
                      {$IFDEF _FULLGAME}
                      PlaySND(snd_pexp,u);
                      _effect_add(vx,vy,vy+map_flydpth[uf]+1,MID_BPlasma);
                      {$ENDIF}
                  end;
        UID_HTotem,
        UID_ArchVile :
           if(tu1^.player<>player)then
           begin
              if(rld=rld_a)
              then _miss_add(tu1^.x,tu1^.y,tu1^.x,tu1^.y,0,MID_ArchFire,player,_tuf(uf,tu1^.uf),false)
              else
              begin
                 _addtoint(@tu1^.vsnt[_players[player].team],vid_fps);
                 _addtoint(@tu1^.vsni[_players[player].team],vid_fps);

                 if((rld mod 20)=0)then dir:=p_dir(x,y,tu1^.x,tu1^.y);
                 {$IFDEF _FULLGAME}
                 if((rld mod 40)=0)then
                  if(_nhp3(tu1^.x,tu1^.y,player))then
                  begin
                     PlaySND(snd_arch_f,tar1);
                     if(tu1^.isbuild)and(tu1^.r>20)then
                     begin
                        ux:=tu1^.r div 2;
                        _effect_add(tu1^.x-random(tu1^.r)+ux,tu1^.y-random(tu1^.r)+ux,tu1^.vy+map_flydpth[tu1^.uf]+1,EID_ArchFire);
                     end
                     else _effect_add(tu1^.x,tu1^.y,tu1^.vy+map_flydpth[tu1^.uf]+1,EID_ArchFire);
                  end;
                 {$ENDIF}
              end;
           end;
        UID_Mancubus:
           begin
              case rld of
              110,
              70,
              30:begin
                    dir:=p_dir(x,y,tu1^.x,tu1^.y);
                    {$IFDEF _FULLGAME} PlaySND(snd_hshoot,u); {$ENDIF}
                    _miss_add(tu1^.x,tu1^.y,vx-7,vy-7,tar1,MID_Mancubus,player,_tuf(uf,tu1^.uf),false);
                    _miss_add(tu1^.x,tu1^.y,vx+7,vy+7,tar1,MID_Mancubus,player,_tuf(uf,tu1^.uf),false);
                 end;
              end;
           end;
        UID_BFG,
        UID_ZBFG:
           if(rld=70)then
           begin
              dir:=p_dir(x,y,tu1^.x,tu1^.y);
              _miss_add(tu1^.x,tu1^.y,vx,vy,tar1,MID_BFG,player,uf_soaring,false);
           end;
       end;

      _addtoint(@vsnt[_players[tu1^.player].team],vid_fps);
      if(OnlySVCode)then
       if(_players[tu1^.player].team<>_players[player].team)then
       begin
          tu1^.alrm_r:=-1;
          tu1^.alrm_x:=x;
          tu1^.alrm_y:=y;
       end;
   end;
end;

function _TarPrioPR(uu,tu:PTUnit):integer;
begin
   _TarPrioPR:=0;

   with uu^ do
   begin
      with _players[player]do
      begin
         if(state=ps_comp)and(ai_skill>3)and(melee=false)then
         begin
            if(tu^.uid in [UID_Pain,UID_BFG,UID_ZBFG])then
            begin
               _TarPrioPR:=10;
               exit;
            end;
            if(ai_skill>4)then
             if(tu^.uid in [UID_HEye,UID_Mine])then
             begin
                _TarPrioPR:=10;
                exit;
             end;
         end;

         if(tu^.isbuild=false)
         then inc(_TarPrioPR,1)
         else
           if(ai_skill>4)and(tu^.bld=false)then inc(_TarPrioPR,1);
         if(tu^.buff[ub_invuln]<=0)then inc(_TarPrioPR,1);
      end;



      case uu^.uid of
      UID_Imp        : if(uid<>tu^.uid)and(tu^.uf=uf_ground)and(tu^.mech=false)then _TarPrioPR:=5;
      UID_Cacodemon  : if(uid<>tu^.uid)and(tu^.uf=uf_ground)then _TarPrioPR:=5;
      UID_Baron      : if(uid<>tu^.uid)and(tu^.uf=uf_ground)and not(tu^.uid in armor_lite)then _TarPrioPR:=5;
      UID_Cyberdemon,
      UID_Bomber,
      UID_Tank,
      UID_Mancubus   : if(tu^.isbuild)then _TarPrioPR:=5;
      UID_Engineer   : if(buff[ub_advanced]=0)then
                       begin if(tu^.mech=false)and(tu^.uid in armor_lite)then _TarPrioPR:=5;end
                       else  if(tu^.mech)and(tu^.buff[ub_toxin]<vid_hfps)then _TarPrioPR:=5;
      UID_Medic      : if(buff[ub_advanced]=0)then
                       begin if(tu^.mech=false)and(tu^.uid in armor_lite)then _TarPrioPR:=5;end
                       else  if(tu^.mech=false)and(tu^.buff[ub_toxin]<vid_hfps)then _TarPrioPR:=5;
      UID_APC,
      UID_FAPC       : if(tu^.mech=false)and(tu^.uid in armor_lite)then _TarPrioPR:=5;
      UID_Sergant,
      UID_ZSergant   : if(tu^.mech=false)and(tu^.uf=uf_ground)then _TarPrioPR:=5;
      UID_Commando,
      UID_ZCommando,
      UID_Terminator,
      UID_Mastermind,
      UID_UTurret    : if(tu^.mech=false)and(tu^.uid in armor_lite)then _TarPrioPR:=5;
      UID_Arachnotron
                     : if(tu^.mech)and(tu^.isbuild=false)then _TarPrioPR:=5;
      UID_UPTurret,
      UID_Major      : if not(tu^.uid in armor_lite)and(tu^.mech)and(tu^.isbuild=false)then _TarPrioPR:=5;
      UID_Mine       : if(tu^.uf<uf_fly)then _TarPrioPR:=5;
      UID_BFG        : if not(tu^.uid in [UID_LostSoul,UID_Demon])then _TarPrioPR:=5;
      UID_HTower,
      UID_Revenant,
      UID_Flyer      : if(tu^.uf>uf_ground)then _TarPrioPR:=5;
      UID_Archvile   : if(tu^.isbuild=false)and(tu^.ucl>2)then _TarPrioPR:=5;
      end;
   end;
end;

function _TarPrioDT(u,ntar:PTUnit;ud:integer):boolean;
var ntar1p:integer;
begin
   _TarPrioDT:=true;

   ntar1p:=_TarPrioPR(u,ntar);
   if(ntar1p=tar1p)then
    if(ud<u^.tar1d)then exit;

   if(ntar1p>tar1p)then
   begin
      tar1p:=ntar1p;
      exit;
   end;

   _TarPrioDT:=false;
end;

{$include _ai.pas}

function _player_sight(player:byte;tu:PTUnit;vision:boolean):boolean;
begin
   _player_sight:=true;

   with _players[player] do
    if(vision)
    then exit
    else
     if(ai_skill>5)and(tu^.isbuild)and(tu^.speed=0)and(tu^.buff[ub_invis]=0)then exit;

   _player_sight:=false;
end;

procedure _u_alarm(u,ud:integer;tu:PTUnit;teams,vision:boolean);
begin
   with _units[u] do
   with _players[player] do
    if(_player_sight(player,tu,vision))then
     if(teams=false)then
     begin
        if(tu^.buff[ub_invuln]>0)then exit;

        if(state=ps_comp)then
         if(tu^.uid in [UID_LostSoul])then exit;

        if(alrm_b=false)or(ud<base_rr)then
         if(ud<alrm_r)then
         begin
            alrm_x:=tu^.x;
            alrm_y:=tu^.y;
            alrm_r:=ud;
            alrm_b:=false;
         end;
     end
     else
       if(state=ps_comp)then
        if not(tu^.uid in [UID_Mine,UID_HEye])then
         if(isbuild=false)and(tu^.alrm_r<base_rr)then
          if(tu^.isbuild)or(tu^.alrm_r<0)then
          begin
             ud:=dist2(x,y,tu^.alrm_x,tu^.alrm_y);
             if(ud<alrm_r)or((tu^.isbuild)and(alrm_b=false))then
              if(ud<base_3r)or(order<>2)then
              begin
                 alrm_x:=tu^.alrm_x;
                 alrm_y:=tu^.alrm_y;
                 alrm_r:=ud;
                 if(tu^.isbuild)and(tu^.uf=uf_ground)then alrm_b:=true;
              end;
          end;
end;

procedure _unit_tardetect(u,t,ud:integer);
var tu:PTUnit;
 vision,
 teams:boolean;
begin
   with _units[u] do
   begin
      tu:=@_units[t];

      with _players[player] do
      begin
         teams:=team=_players[tu^.player].team;

         if(tu^.hits>0)then
         begin
            vision:=_uvision(team,tu,false);

            if(onlySVCode)and(vision)then  _unit_aiUBC(u,tu,ud,teams);

            _u_alarm(u,ud,tu,teams,vision);
         end;
      end;

      if(onlySVCode)then
      begin
         with _players[player] do
          if(bld)and(tu^.hits>0)then
          begin
             if(uid=UID_HKeep)then
              if(upgr[upgr_paina]>0)and(ud<sr)then
               if(teams=false)then
               begin
                  if not(tu^.uid in [UID_HEye,UID_Mine,UID_Demon])then _unit_damage(t,upgr[upgr_paina] shl 1,upgr[upgr_paina],player);
               end
               else tu^.buff[ub_toxin]:=-vid_fps;
          end;

         if(uo_id=ua_amove)then
         begin
            if(buff[ub_cast]>0)and(uid=UID_Archvile)then exit;
            //if(rld>0)and(uid=UID_Archvile)then exit;

            if(_unit_target(u,tu,ud,false)>0)then
             if(_TarPrioDT(@_units[u],tu,ud))then
             begin
                tar1 :=t;
                tar1d:=ud;
             end;
         end;
      end;
   end;
end;

procedure _unit_code1_n(u:integer);
var uc,
    ud:integer;
    tu:PTUnit;
begin
   with _units[u] do
   begin
      if(alrm_r<0)
      then alrm_r:=0
      else alrm_r:=32000;

      tar1d   := 32000;
      tar1    := 0;
      tar1p   := 0;

      if(0<inapc)and(inapc<=MaxUnits)then
      begin
         if(_units[inapc].inapc>0)then exit;
         vsnt:=_units[inapc].vsnt;

         if(OnlySVCode)then
         case uid of
         UID_Engineer: begin
                          tu:=@_units[inapc];
                          if(tu^.buff[ub_pain]=0)then
                           if(tu^.hits<tu^.mhits)then
                           begin
                              tar1 :=inapc;
                              tar1d:=0;
                              tar1p:=11;
                           end;
                       end;
         end;
      end;

      for uc:=1 to MaxUnits do
       if(uc<>u)then
       begin
          tu:=@_units[uc];
          if(tu^.hits>dead_hits)then
          begin
             ud:=dist2(x,y,tu^.x,tu^.y);
             if(inapc=0)then _udetect(@_units[u],tu,ud);
             if(tu^.hits>0)and(tu^.inapc=0)then _unit_tardetect(u,uc,ud);
          end;
       end;

      {$IFDEF _FULLGAME}
      if(player=HPlayer)and(alrm_r<sr)and(alrm_b=false)then ui_addalrm(mmx,mmy,isbuild);
      {$ENDIF}
   end;
end;

procedure _unit_cp(u:integer);
var i : byte;
    ud:integer;
begin
   with _units[u] do
   with _players[player] do
   begin
      for i:=1 to MaxPlayers do
       with g_ct_pl[i] do
       begin
          ud:=dist2(x,y,px,py);

          if(ud<=g_ct_pr)and(_players[pl].team<>team)then
           if(ct<g_ct_ct[race])
           then inc(ct,vid_hfps)
           else
             if(ct>=g_ct_ct[race])then
             begin
                pl:=player;
                ct:=0;
             end;

          if(_players[pl].team<>team)or(pl=0)or(ct>0)then
          begin
             if(ud<ai_ptd)then
             begin
                ai_ptd:=ud;
                ai_pt :=i;
             end;
          end;
       end;

      if(ai_pt>0)then
      begin
         alrm_x:=g_ct_pl[ai_pt].px;
         alrm_y:=g_ct_pl[ai_pt].py;
      end;
   end;
end;

procedure _unit_code1(u:integer);
var uc,
    ud   :integer;
    tu   :PTUnit;
    push :boolean;
begin
   with _units[u] do
   with _players[player] do
   begin
      ai_pt :=0;
      ai_ptd:=32000;

      if(g_mode=gm_ct)and(isbuild=false)then _unit_cp(u);

      if(state=ps_comp)then _unit_ai0(u);

      if(uf>uf_ground)and(apcm>0)and(apcc>0)and(uo_id=ua_unload)then
       if(_unit_OnDecorCheck(x,y))then uo_id:=ua_move;

      tar1d   := 32000;
      tar1    := 0;
      tar1p   := 0;
      push    := solid and _canmove(u);
      if(alrm_r<0)
      then inc(alrm_r,1)
      else alrm_r:=32000;
      alrm_b  :=false;

      for uc:=1 to MaxUnits do
       if(uc<>u)then
       begin
          tu:=@_units[uc];

          if(tu^.hits>0)then
          begin
             if(tu^.inapc>0)then // unload
             begin
                if(tu^.inapc=u)and(uo_id=ua_unload)then
                begin
                   if(apcc>0)then
                   begin
                      dec(apcc,tu^.apcs);
                      tu^.inapc:=0;
                      tu^.x    :=tu^.x-20+random(40);
                      tu^.y    :=tu^.y-20+random(40);
                      tu^.uo_x :=tu^.x;
                      tu^.uo_y :=tu^.y;
                   end;
                   if(apcc=0)then
                   begin
                      {$IFDEF _FULLGAME}
                      PlaySND(snd_inapc,u);
                      {$ENDIF}
                      uo_id:=ua_amove;
                   end;
                end;
                continue;
             end;

             ud:=dist2(x,y,tu^.x,tu^.y);

             _udetect(@_units[u],tu,ud);
             _unit_tardetect(u,uc,ud);

             if(push)then
              if(r<=tu^.r)or(tu^.speed=0)then
               if(tu^.solid)and(sign(uf)=sign(tu^.uf))and(ud<sr)then _unit_push(u,uc,ud);

             dec(ud,r+tu^.r);

             if(player=tu^.player)then
             begin
                if(state=ps_comp)then
                 if(_unit_aiC(u,uc,ud,tu))then continue;

                if(ud<melee_r)then
                 if(uo_tar=uc)or(tu^.uo_tar=u)then
                  if(_itcanapc(@_units[u],tu))then
                  begin
                     if(state=ps_comp)and(order<>1)then tu^.order:=order;
                     inc(apcc,tu^.apcs);
                     tu^.inapc:=u;
                     tu^.tar1 :=0;
                     if(uo_tar=uc)then uo_tar:=0;
                     if(tu^.uo_tar=u)then tu^.uo_tar:=0;
                     {$IFDEF _FULLGAME}
                     PlaySND(snd_inapc,u);
                     {$ENDIF}
                     if(tu^.sel)then
                     begin
                        dec(u_s [tu^.isbuild,tu^.ucl],1);
                        dec(u_cs[tu^.isbuild],1);
                        tu^.sel:=false;
                     end;
                  end;
             end;
          end
          else
            if(tu^.hits>dead_hits)then
            begin
               ud:=dist2(x,y,tu^.x,tu^.y);
               _udetect(@_units[u],tu,ud);
               _unit_tardetect(u,uc,ud);
            end;
       end;

      _unit_npush2(u);

      {$IFDEF _FULLGAME}
      if(player=HPlayer)and(alrm_r<sr)and(alrm_b=false)then ui_addalrm(mmx,mmy,isbuild);
      {$ENDIF}

      case uid of
      UID_Medic   : if(x=mv_x)and(y=mv_y)then
                     if(tar1=0)and(hits<mhits)then
                     begin
                        tar1 :=u;
                        tar1d:=0;
                     end;
      end;

      {$IFDEF _FULLGAME}
      if(_testdmg=false)then
      {$ENDIF}
      if(state=ps_comp)then _unit_ai1(u);
   end;
end;

function _u1_spawn(u,sx,sy:integer):boolean;
begin
  _u1_spawn:=false;
   with _units[u] do
    with _players[player] do
    begin
       if(sy=32000)then sy:=r;
       _unit_add(x+sx,y+sy+_ulst[cl2uid[race,false,utrain]].r,cl2uid[race,false,utrain],player,true);
       if(_lcu>0)then
       begin
          _u1_spawn:=true;
          _lcup^.uo_x   :=uo_x;
          _lcup^.uo_y   :=uo_y;
          _lcup^.uo_id  :=uo_id;
          _lcup^.uo_tar :=uo_tar;
          _unit_turn(_lcu);

          if(uid=uid_HGate)then
          begin
             _lcup^.buff[ub_teleeff]:=vid_fps;
             {$IFDEF _FULLGAME}
             PlaySND(snd_teleport,u);
             _effect_add(_lcup^.x,_lcup^.y,_lcup^.y+map_flydpth[_lcup^.uf]+5,EID_Teleport);
             {$ENDIF}
          end;
       end;
    end;
end;

procedure _unit_portalspawn(u:integer;uids:TSoB);
begin
   with _units[u] do
   with _players[player] do
   if(rld=0)then
   begin
      repeat
         inc(utrain,1);
      until utrain in uids;

      _unit_add(x,y,utrain,player,true);

      if(_lcu>0)then
      begin
         _lcup^.buff[ub_teleeff]:=vid_fps;
         {$IFDEF _FULLGAME}
         PlaySND(snd_teleport,u);
         _effect_add(_lcup^.x,_lcup^.y,_lcup^.y+map_flydpth[_lcup^.uf]+5,EID_Teleport);
         {$ENDIF}
      end;

      rld:=army;
   end;
end;

procedure _unit_code2(u:integer);
begin
   with _units[u] do
   with _players[player] do
   begin
      if(onlySVCode)then
      begin
         {$IFDEF _FULLGAME}
         if(player=0)and(_testdmg)then
          if(sel)then
          begin
             if(k_shift>2)then
             begin
                if(sel)then
                begin
                   dec(u_s [isbuild,ucl],1);
                   dec(u_cs[isbuild],1);
                end;
                sel:=false;
             end;

             x :=m_mx;
             y :=m_my;
             vx:=m_mx;
             vy:=m_my;

             _unit_mmcoords(u);
             _unit_sfog(u);

             if(hits<mhits)then
             begin
                bld_s :=mhits-hits;
                hits:=mhits;
             end;
          end;
         {$ENDIF}

         if(_uclord_c=_uclord)then
         begin
            case uid of
            UID_HEye: if(hits>1)
                      then dec(hits,1)
                      else begin _unit_kill(u,false,false);exit;end;
            end;
            if(g_mode=gm_royl)then
             if(dist(x,y,map_cx,map_cx)>=g_royal_r)then
             begin
                _unit_kill(u,false,false);
                exit;
             end;
         end;

         if(isbuild)then
         begin
            if(menerg=0)
            then _unit_kill(u,false,false)
            else
              if(bld=false)then
              begin
                 if(menerg<cenerg)
                 then _unit_kill(u,false,false)
                 else
                   if(buff[ub_pain]=0)then
                   begin
                      {$IFDEF _FULLGAME}
                      if(_warpten)
                      then hits:=mhits
                      else
                      {$ENDIF}
                        if(_uclord_c<>_uclord)then exit;
                      inc(hits,bld_s);
                      if(upgr[upgr_advbld]>0)then inc(hits,bld_s);
                      if(hits>=mhits)then
                      begin
                         hits:=mhits;
                         bld :=true;
                         inc(u_eb[isbuild,ucl],1);
                         inc(uid_b[uid],1);

                         inc(menerg,generg);
                         dec(cenerg,_ulst[cl2uid[race,true,ucl]].renerg);
                         if(ucl=0)then inc(bldrs,1);
                      end;
                   end;
              end
              else
              begin
                 if(rld>0)then
                 begin
                    if(ucl=1)then
                     if((army+wb)>MaxPlayerUnits)or(menerg<cenerg)or(u_e[false,utrain]>=_ulst[cl2uid[race,false,utrain]].max)
                     then _unit_ctraining(u)
                     else
                       if(rld=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
                       begin
                          if(_ulst[cl2uid[race,false,utrain]].max=1)then dec(wbhero,1);
                          dec(wb,1);
                          rld:=0;
                          dec(cenerg,_ulst[cl2uid[race,false,utrain]].renerg);

                          if(_u1_spawn(u,0,32000))and(player=HPlayer)then {$IFDEF _FULLGAME}_unit_createsound(cl2uid[race,false,utrain]);{$ELSE};{$ENDIF}

                          if(buff[ub_advanced]>0)then _u1_spawn(u,30,32000);
                       end;

                    if(ucl=3)then
                     if(menerg<cenerg)then
                     begin
                        rld:=0;
                        dec(cenerg,_pne_r[race,utrain]);
                        dec(upgrinp[utrain],1);
                     end
                     else
                       if(rld=1){$IFDEF _FULLGAME}or(_warpten){$ENDIF}then
                       begin
                          rld:=0;
                          inc(upgr[utrain],1);
                          dec(upgrinp[utrain],1);
                          dec(cenerg,_pne_r[race,utrain]);
                       end;
                 end;

                 if(uid=UID_CoopPortal)then _unit_portalspawn(u,coopspawn);
              end;
         end;
      end;

      if(hits>0)and(isbuild)and(bld)then
       if(ubx[ucl]=0)then ubx[ucl]:=u;
   end;
end;

procedure _unit_uo_tar(u:integer);
var tu: PTUnit;
td,tdm: integer;
teams : boolean;
begin
   with _units[u] do
   begin
      if(uo_tar=u)then uo_tar:=0;
      if(uo_tar>0)and(inapc=0)then
      begin
         tu:=@_units[uo_tar];
         if(tu^.inapc>0)then
         begin
            uo_tar:=0;
            exit;
         end;

         td :=dist2(x,y,tu^.x,tu^.y);
         tdm:=td-(r+tu^.r);

         if(player=tu^.player)then
         begin
            /// HELL ADV
            if(uid=UID_HMonastery)and(tu^.isbuild=false)then
            begin
               with _players[player] do
                if(tu^.buff[ub_advanced]=0)and(bld)and(upgr[upgr_6bld]>0)and(buff[ub_advanced]>0)then
                begin
                   dec(upgr[upgr_6bld],1);
                   tu^.buff[ub_advanced]:=_bufinf;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(uo_tar,snd_hupgr);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            if(tu^.uid=UID_HMonastery)and(isbuild=false)then
            begin
               with _players[player] do
                if(buff[ub_advanced]=0)and(tu^.bld)and(upgr[upgr_6bld]>0)then
                begin
                   dec(upgr[upgr_6bld],1);
                   buff[ub_advanced]:=_bufinf;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(u,snd_hupgr);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            /// HELL INVULN
            if(uid=UID_HAltar)and(tu^.isbuild=false)then
            begin
               with _players[player] do
                if(tu^.buff[ub_invuln]=0)and(bld)and(upgr[upgr_hinvuln]>0)then
                begin
                   dec(upgr[upgr_hinvuln],1);
                   tu^.buff[ub_invuln]:=hinvuln_time;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(uo_tar,snd_hpower);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            if(tu^.uid=UID_HAltar)and(isbuild=false)then
            begin
               with _players[player] do
                if(buff[ub_invuln]=0)and(tu^.bld)and(upgr[upgr_hinvuln]>0)then
                begin
                   dec(upgr[upgr_hinvuln],1);
                   buff[ub_invuln]:=hinvuln_time;
                   {$IFDEF _FULLGAME}
                   _unit_PowerUpEff(u,snd_hpower);
                   {$ENDIF}
                end;
               uo_x  :=x;
               uo_y  :=y;
               uo_tar:=0;
               exit;
            end;
            // UAC ADV
            if(tu^.uid=UID_UVehicleFactory)then
             if(tdm<=melee_r)and(tu^.rld=0)and(isbuild=false)then
             begin
                uo_x  :=x;
                uo_y  :=y;
                uo_tar:=0;
                if(tu^.buff[ub_advanced]>0)and(tu^.bld)and(buff[ub_advanced]=0)then
                begin
                   _unit_UACUpgr(u,tu);
                   uo_x  :=tu^.uo_x;
                   uo_y  :=tu^.uo_y;
                   uo_tar:=tu^.uo_tar;
                end;
                exit;
             end;
         end;

         teams:=_players[player].team=_players[tu^.player].team;

         if(teams=false)then
          if(_uvision(_players[player].team,tu,false)=false)then
          begin
             uo_tar:=0;
             exit;
          end
          else
          begin
             tar1 :=uo_tar;
             uo_id:=ua_amove;
          end;

         if(_move2uotar(@_units[u],tu,td))then
         begin
            uo_x:=tu^.vx;
            uo_y:=tu^.vy;
         end;

         if(teams)then
          if(tu^.uid=UID_HTeleport)and(tu^.bld)and(isbuild=false)then
           if(td<=tu^.r)then
           begin
              if(dist2(x,y,tu^.uo_x,tu^.uo_y)>tu^.sr)and(tu^.rld=0) then
              begin
                 if(uf=uf_ground)then
                  if(tu^.buff[ub_cnttrans]>0)
                  then exit
                  else
                    if(_unit_OnDecorCheck(tu^.uo_x,tu^.uo_y))then exit;

                 _unit_teleport(u,tu^.uo_x,tu^.uo_y);
                 _teleport_rld(tu,mhits);
                 exit;
              end;
           end
           else
             if(tu^.buff[ub_advanced]>0)and(td>base_rr)then
              if(tu^.rld=0)then
              begin
                 _unit_teleport(u,tu^.x,tu^.y);
                 _teleport_rld(tu,mhits);
                 exit;
              end
              else
              begin
                 uo_x:=x;
                 uo_y:=y;
              end;
      end;
   end;
end;

procedure _unit_order(u:integer);
var tu:PTUnit;
    td:integer;
    i :byte;
begin
   with _units[u] do
   begin
      if(onlySVCode)then
      begin
         _unit_uo_tar(u);
         mv_x:=uo_x;
         mv_y:=uo_y;

         if(uo_id=ua_paction)then
         case uid of
UID_Pain: begin
             mv_x:=x;
             mv_y:=y;
             uo_id:=ua_amove;
             _pain_action_code(u);
             uo_id:=ua_paction;
          end;
         end;

         if(x=uo_x)and(y=uo_y)then
          if(uo_id=ua_paction)then
          begin
             uo_id:=ua_amove;
             _unit_action(u);
          end
          else
            if(uo_bx>=0)then
            begin
               uo_x :=uo_bx;
               uo_bx:=x;
               uo_y :=uo_by;
               uo_by:=y;
               _unit_turn(u);
            end
            else
              if(uo_id=ua_move)then uo_id:=ua_amove;

         if(buff[ub_stopafa]>0)then
         begin
            mv_x:=x;
            mv_y:=y;
         end;
      end;

      tar1d:=32000;
      if(0<tar1)and(tar1<=MaxUnits)then
      begin
         tu:=@_units[tar1];
         td:=dist2(x,y,tu^.x,tu^.y);
         i :=_unit_target(u,tu,td,false);
         if(onlySVCode)then
           case i of
         0 : tar1 :=0;
         1 : begin
                mv_x :=tu^.x;
                mv_y :=tu^.y;
                tar1d:=td;
             end;
         2,3
           : begin
                tar1d:=td;
                melee:=(i=3);
                if(_canattack(u))then _unit_attack(u);
                if(inapc>0)then exit;
                if(tar1=uo_tar)then
                begin
                   uo_x:=x;
                   uo_y:=y;
                end
                else
                  if(tar1<>u)then
                   case uid of
                   UID_APC,
                   UID_FAPC,
                   UID_UCommandCenter : exit;
                   else
                   end;
                mv_x :=x;
                mv_y :=y;
                if(x<>tu^.x)or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
                if(rld>0)and(buff[ub_stopafa]=0)then
                 if(_uclord_p>rld)
                 then buff[ub_stopafa]:=_uclord_p
                 else buff[ub_stopafa]:=rld;
             end;
           end
         else
           case i of
          2,3
            : begin
                 tar1d:=td;
                 melee:=(i=3);
                 if(_canattack(u))then _unit_attack(u);
                 if(inapc>0)then exit;
                 if(tar1<>u)then
                  case uid of
                  //UID_Flyer : if(buff[ub_advanced]>0)then exit;
                  UID_APC,
                  UID_FAPC,
                  UID_UCommandCenter : exit;
                  else
                  end;
                 if(x<>tu^.x)or(y<>tu^.y)then dir:=p_dir(x,y,tu^.x,tu^.y);
              end;
           end;
      end;
   end;
end;

procedure _obj_cycle(onlyspr:boolean);
var u : integer;
    i : byte;
begin
   for u:=1 to MaxUnits do
    with _units[u] do
     if(hits>dead_hits)then
     begin
        if(onlyspr=false)then
        begin
           with _players[player] do
           begin
              _addtoint(@vsnt[team],vistime);
              _addtoint(@vsni[team],vistime);
              if(onlySVCode)then
               if(_uclord=_uclord_c)then
               begin
                  if{$IFDEF _FULLGAME}(menu_s2<>ms2_camp)and{$ENDIF}(u_e[true,0]=0)then
                   for i:=0 to MaxPlayers do
                   begin
                      _addtoint(@vsnt[i],vid_fps);
                      if(g_mode<>gm_inv)or(player<>0)then _addtoint(@vsni[i],vid_fps);
                   end;
               end;
           end;

           if(hits>0)then
           begin
              _unit_counters(u);
              _unit_upgr    (u);
              _unit_order   (u);
              _unit_move    (u);
              _unit_movevis (u);
              if(_uclord=_uclord_c)then
               if(onlySVCode)and(inapc=0)
               then _unit_code1  (u)
               else _unit_code1_n(u);
              if(hits>0)then _unit_code2(u);
           end
           else _unit_death(u);
        end;

        {$IFDEF _FULLGAME}
         if(hits>0)
         then _unit_vis(u,onlyspr)
         else _unit_dvis(u);
        {$ENDIF}
     end;

   _missileCycle(onlyspr);
   {$IFDEF _FULLGAME}
   _dds_p(onlyspr);
   _effectsCycle(true,onlyspr);
   {$ENDIF}
end;

////////////////////////////////////////////////////////////////////////////////




