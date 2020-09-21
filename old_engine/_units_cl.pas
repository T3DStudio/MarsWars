
{$IFDEF _FULLGAME}
procedure InitFogR;
var r,x:byte;
begin
   for r:=0 to MFogM do
    for x:=0 to r do
     _fcx[r,x]:=trunc(sqrt(sqr(r)-sqr(x)));
end;

procedure _unit_fsrclc(u:PTUnit);
begin
   with u^ do
   begin
      fsr:=0;
      if(fog_cw>0)then
      begin
         fsr:=sr div fog_cw;
         if(fsr>MFogM)then fsr:=MFogM;
      end;
   end;
end;
{$ENDIF}

procedure _unit_sclass(u:PTUnit);
var ctime:integer;
begin
   with u^ do
   begin
      ctime   := 0;

      ucl     := 0;
      generg  := 0;
      isbuild := false;
      apcs    := 1;
      apcm    := 0;
      mech    := false;
      mmr     := 0;
      shadow  := 0;
      painc   := 0;
      rld_a   := 0;
      rld_r   := 0;
      solid   := true;
      max     := 255;
      mhits   := 100;
      speed   := 0;
      anims   := 0;
      trt     := 0;
      bld_s   := 18;
      mdmg    := 5;
      ar      := 0;
      arf     := -1;
      renerg  := 0;
      generg  := 0;
      ruid    := 255;
      rupgr   := 255;

      if(uid=UID_LostSoul)then
      begin
         mhits  := 90;
         r      := 10;
         uf     := uf_soaring;
         speed  := 23;
         sr     := 250;
         ucl    := 0;
         painc  := 3;
         rld_r  := 60;
         rld_a  := 20;
         mdmg   := 10;
         trt    := vid_fps*8;
         renerg := 1;
      end;
      if(uid=UID_Imp) then
      begin
         mhits  := 70;
         r      := 12;
         uf     := uf_ground;
         speed  := 9;
         sr     := 250;
         ucl    := 1;
         painc  := 3;
         rld_r  := 60;
         rld_a  := 25;
         anims  := 12;
         mdmg   := 10;
         trt    := vid_fps*5;
         renerg := 1;
      end;
      if(uid=UID_Demon) then
      begin
         mhits  := 150;
         r      := 14;
         uf     := uf_ground;
         speed  := 14;
         sr     := 200;
         ucl    := 2;
         painc  := 8;
         rld_r  := 60;
         rld_a  := 25;
         anims  := 15;
         mdmg   := 40;
         trt    := vid_fps*8;
         renerg := 2;
      end;
      if(uid=UID_CacoDemon)then
      begin
         mhits  := 225;
         r      := 14;
         uf     := uf_fly;
         speed  := 9;
         sr     := 250;
         ucl    := 3;
         painc  := 6;
         rld_r  := 75;
         rld_a  := 45;
         mdmg   := 30;
         trt    := vid_fps*20;
         renerg := 2;
      end;
      if(uid=UID_Baron)then
      begin
         mhits  := 350;
         r      := 14;
         uf     := uf_ground;
         speed  := 9;
         sr     := 250;
         ucl    := 4;
         painc  := 8;
         rld_r  := 75;
         rld_a  := 45;
         anims  := 12;
         mdmg   := 50;
         trt    := vid_fps*40;
         renerg := 4;
         arf    :=(sr div 4)*3;
      end;
      if(uid=UID_Cyberdemon)then
      begin
         mhits  := 2000;
         r      := 20;
         uf     := uf_ground;
         speed  := 10;
         sr     := 250;
         ucl    := 5;
         painc  := 15;
         rld_r  := 70;
         rld_a  := 50;
         anims  := 11;
         max    := 1;
         trt    := vid_fps*90;
         renerg := 8;
         ruid   := UID_HMonastery;
         arf    :=(sr div 4)*3;
      end;
      if(uid=UID_Mastermind) then
      begin
         mhits  := 2000;
         r      := 35;
         uf     := uf_ground;
         speed  := 10;
         sr     := 250;
         ucl    := 6;
         painc  := 15;
         rld_r  := 7;
         rld_a  := 4;
         anims  := 11;
         max    := 1;
         trt    := vid_fps*90;
         renerg := 8;
         ruid   := UID_HMonastery;
         arf    :=(sr div 4)*3;
      end;
      if(uid=UID_Pain)then
      begin
         mhits  := 200;
         r      := 14;
         uf     := uf_fly;
         speed  := 9;
         sr     := 250;
         ar     := 350;
         ucl    := 7;
         painc  := 3;
         rld_r  := 95;
         rld_a  := 70;
         anims  := 7;
         trt    := vid_fps*40;
         renerg := 6;
         ruid   := UID_HMonastery;
      end;
      if(uid=UID_Revenant) then
      begin
         mhits  := 200;
         r      := 13;
         uf     := uf_ground;
         speed  := 12;
         sr     := 250;
         ucl    := 8;
         painc  := 7;
         rld_r  := 75;
         rld_a  := 45;
         anims  := 16;
         mdmg   := 35;
         trt    := vid_fps*40;
         renerg := 4;
         ruid   := UID_HMonastery;
      end;
      if(uid=UID_Mancubus) then
      begin
         mhits  := 400;
         r      := 20;
         uf     := uf_ground;
         speed  := 6;
         sr     := 250;
         ar     := 300;
         ucl    := 9;
         painc  := 4;
         rld_r  := 150;
         anims  := 10;
         trt    := vid_fps*60;
         renerg := 6;
         ruid   := UID_HMonastery;
         rupgr  := upgr_2tier;
         arf    :=(ar div 2);
      end;
      if(uid=UID_Arachnotron) then
      begin
         mhits  := 350;
         r      := 20;
         uf     := uf_ground;
         speed  := 8;
         sr     := 250;
         ar     := 250;
         ucl    := 10;
         painc  := 4;
         rld_r  := 15;
         anims  := 11;
         trt    := vid_fps*60;
         renerg := 6;
         ruid   := UID_HMonastery;
         rupgr  := upgr_2tier;
      end;
      if(uid=UID_ArchVile) then
      begin
         mhits  := 400;
         r      := 15;
         uf     := uf_ground;
         speed  := 15;
         sr     := 250;
         ar     := 400;
         ucl    := 11;
         painc  := 12;
         rld_r  := 140;
         rld_a  := 65;
         anims  := 15;
         trt    := vid_fps*90;
         renerg := 10;
         ruid   := UID_HAltar;
         rupgr  := upgr_2tier;
      end;

      if(uid=UID_HEye) then
      begin
         mhits  := 240;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 12;
         r      := 10;
         isbuild:= false;
         bld_s  := 8;
         isbuild:= true;
         buff[ub_detect]:=_bufinf;
         rld_a  := vid_fps;
      end;


      if(uid=UID_HKeep)then
      begin
         mhits  := 3000;
         uf     := uf_ground;
         sr     := base_rA[0];
         ucl    := 0;
         r      := 66;
         generg := 6;
         isbuild:= true;
         renerg := 8;
         ctime  := 75;
      end;
      if(uid in [UID_HGate,UID_HMilitaryUnit]) then
      begin
         mhits  := 1500;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 1;
         if(uid=UID_HMilitaryUnit)
         then r      := 70
         else r      := 60;
         generg := 0;
         isbuild:= true;
         rld_a  := 12;
         renerg := 4;
         ctime  := 40;
      end;
      if(uid=UID_HSymbol) then
      begin
         mhits  := 200;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 2;
         r      := 24;
         generg := 1;
         isbuild:= true;
         renerg := 1;
         ctime  := 10;
      end;
      if(uid=UID_HPools) then
      begin
         mhits  := 1000;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 3;
         r      := 53;
         generg := 0;
         isbuild:= true;
         renerg := 6;
         ctime  := 40;
      end;
      if(uid=UID_HTower) then
      begin
         mhits  := 700;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 4;
         r      := 21;
         generg := 0;
         isbuild:= true;
         rld_r  := 40;
         renerg := 2;
         ctime  := 20;
      end;
      if(uid=UID_HTeleport) then
      begin
         mhits  := 500;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 5;
         r      := 28;
         generg := 0;
         isbuild:= true;
         solid  := false;
         max    := 1;
         renerg := 4;
         ctime  := 25;
      end;
      if(uid=UID_HMonastery)then
      begin
         mhits  := 1000;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 6;
         r      := 65;
         isbuild:= true;
         max    := 1;
         renerg := 10;
         ctime  := 90;
         ruid   := UID_HPools;
      end;
      if(uid=UID_HTotem) then
      begin
         mhits  := 600;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 7;
         r      := 21;
         generg := 0;
         isbuild:= true;
         rld_r  := 140;
         rld_a  := 65;
         renerg := 3;
         ctime  := 25;
         ruid   := UID_HMonastery;
         rupgr  := upgr_2tier;
      end;
      if(uid=UID_HAltar) then
      begin
         mhits  := 750;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 8;
         r      := 50;
         isbuild:= true;
         max    := 1;
         renerg := 4;
         ctime  := 30;
         ruid   := UID_HMonastery;
         rupgr  := upgr_2tier;
      end;

////////////////////////////////////////////////////////////////////////////////

      if(uid=UID_Engineer)then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 13;
         sr     := 220;
         ucl    := 0;
         rld_r  := 35;
         rld_a  := 25;
         anims  := 18;
         mdmg   := 6;
         trt    := vid_fps*8;
         renerg := 1;
         arf    :=(sr div 4)*3;
      end;
      if(uid in [UID_Medic,UID_ZFormer])then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 13;
         sr     := 220;
         ucl    := 1;
         rld_r  := 40;
         rld_a  := 30;
         anims  := 18;
         mdmg   := 6;
         trt    := vid_fps*8;
         renerg := 1;
         if(uid=UID_ZFormer)then
         begin
            painc  := 3;
            ucl    := 12;
            speed  := 10;
            anims  := 14;
            rld_a  := 22;
            trt    := vid_fps*5;
         end;
         arf    :=(sr div 4)*3;
      end;
      if(uid in [UID_Sergant,UID_ZSergant])then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 13;
         sr     := 241;
         ucl    := 2;
         rld_r  := 60;
         rld_a  := 40;
         anims  := 18;
         trt    := vid_fps*10;
         renerg := 2;
         if(uid=UID_ZSergant)then
         begin
            renerg := 1;
            painc  := 3;
            ucl    := 12;
            speed  := 10;
            anims  := 14;
         end;
         arf    :=(sr div 4)*3;
      end;
      if(uid in [UID_Commando,UID_ZCommando])then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 11;
         sr     := 250;
         ucl    := 3;
         rld_r  := 8;
         rld_a  := 3;
         anims  := 15;
         trt    := vid_fps*15;
         renerg := 2;
         if(uid=UID_ZCommando)then
         begin
            renerg := 1;
            painc  := 3;
            ucl    := 12;
            rld_r  := 10;
         end;
         arf    :=220;
      end;
      if(uid in [UID_Bomber,UID_ZBomber])then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 10;
         sr     := 250;
         ucl    := 4;
         rld_r  := 100;
         rld_a  := 80;
         anims  := 14;
         trt    := vid_fps*30;
         renerg := 4;
         if(uid=UID_ZBomber)then
         begin
            renerg := 1;
            painc  := 3;
            ucl    := 12;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uid in [UID_Major,UID_ZMajor])then
      begin
         mhits  := 100;
         r      := 13;
         uf     := uf_ground;
         speed  := 9;
         sr     := 250;
         ucl    := 5;
         rld_r  := 15;
         rld_a  := 0;
         anims  := 14;
         trt    := vid_fps*20;
         renerg := 4;
         if(uid=UID_ZMajor)then
         begin
            renerg := 1;
            painc  := 3;
            ucl    := 12;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uid in [UID_BFG,UID_ZBFG])then
      begin
         mhits  := 100;
         r      := 12;
         uf     := uf_ground;
         speed  := 10;
         sr     := 250;
         ucl    := 6;
         rld_r  := 150;
         rld_a  := 40;
         anims  := 14;
         trt    := vid_fps*60;
         renerg := 5;
         if(uid=UID_ZBFG)then
         begin
            renerg := 1;
            painc  := 3;
            ucl    := 12;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uid=UID_FAPC)then
      begin
         mhits  := 250;
         r      := 33;
         uf     := uf_fly;
         speed  := 22;
         sr     := 250;
         ucl    := 7;
         mech   := true;
         apcm   := 10;
         rld_r  := 110;
         trt    := vid_fps*25;
         renerg := 3;
         ruid   := UID_UWeaponFactory;
      end;
      if(uid=UID_APC)then
      begin
         mhits  := 350;
         r      := 25;
         uf     := uf_ground;
         speed  := 15;
         sr     := 250;
         ucl    := 8;
         mech   := true;
         apcm   := 4;
         apcs   := 8;
         anims  := 17;
         trt    := vid_fps*25;
         renerg := 3;
         ruid   := UID_UWeaponFactory;
      end;
      if(uid=UID_Terminator)then
      begin
         mhits  := 350;
         r      := 16;
         uf     := uf_ground;
         speed  := 14;
         sr     := 275;
         ucl    := 9;
         mech   := true;
         apcs   := 3;
         rld_r  := 8;
         rld_a  := 0;
         anims  := 18;
         trt    := vid_fps*60;
         renerg := 6;
         ruid   := UID_UVehicleFactory;
         rupgr  := upgr_2tier;
         //arf    :=(sr div 4)*3;
      end;
      if(uid=UID_Tank)then
      begin
         mhits  := 400;
         r      := 20;
         uf     := uf_ground;
         speed  := 10;
         sr     := 250;
         ucl    := 10;
         mech   := true;
         apcs   := 7;
         rld_r  := 100;
         rld_a  := 85;
         anims  := 17;
         trt    := vid_fps*60;
         renerg := 8;
         ruid   := UID_UVehicleFactory;
         rupgr  := upgr_2tier;
      end;
      if(uid=UID_Flyer)then
      begin
         mhits  := 350;
         r      := 18;
         uf     := uf_fly;
         speed  := 19;
         sr     := 275;
         ucl    := 11;
         mech   := true;
         rld_r  := 30;
         rld_a  := (rld_r div 3)*2;
         trt    := vid_fps*60;
         renerg := 8;
         ruid   := UID_UVehicleFactory;
         rupgr  := upgr_2tier;
      end;


      if(uid=UID_UCommandCenter)then
      begin
         mhits  := 4000;
         uf     := uf_ground;
         sr     := base_rA[0];
         ar     := 250;
         ucl    := 0;
         r      := 66;
         generg := 6;
         isbuild:= true;
         renerg := 8;
         ctime  := 90;
      end;
      if(uid=UID_UMilitaryUnit)then
      begin
         mhits  := 1700;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 1;
         r      := 66;
         isbuild:= true;
         renerg := 4;
         ctime  := 40;
      end;
      if(uid=UID_UGenerator) then
      begin
         mhits  := 400;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 2;
         r      := 42;
         generg := 2;
         isbuild:= true;
         renerg := 2;
         ctime  := 20;
      end;
      if(uid=UID_UWeaponFactory) then
      begin
         mhits  := 1700;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 3;
         r      := 62;
         isbuild:= true;
         renerg := 6;
         ctime  := 40;
      end;
      if(uid=UID_UTurret) then
      begin
         mhits  := 400;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 4;
         r      := 17;
         isbuild:= true;
         rld_r  := 14;
         rld_a  := rld_r div 2;
         anims  := 3;
         renerg := 2;
         ctime  := 15;
      end;
      if(uid=UID_URadar) then
      begin
         mhits  := 500;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 5;
         r      := 35;
         isbuild:= true;
         max    := 1;
         renerg := 2;
         ctime  := 30;
      end;
      if(uid=UID_UVehicleFactory) then
      begin
         mhits  := 1700;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 6;
         r      := 62;
         isbuild:= true;
         max    := 1;
         renerg := 10;
         ctime  := 90;
         ruid   := UID_UWeaponFactory;
      end;
      if(uid=UID_UPTurret) then
      begin
         mhits  := 400;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 7;
         r      := 17;
         isbuild:= true;
         rld_r  := 15;
         rld_a  := rld_r div 2;
         anims  := 2;
         renerg := 2;
         ctime  := 20;
         ruid   := UID_UWeaponFactory;
      end;
      if(uid=UID_URTurret) then
      begin
         mhits  := 500;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 4;
         r      := 17;
         isbuild:= true;
         rld_r  := 90;
         rld_a  := 0;
         anims  := 2;
         renerg := 2;
         ctime  := 20;
         ruid   := UID_UWeaponFactory;
         arf    := (sr div 5)*4;
      end;
      if(uid=UID_URocketL) then
      begin
         mhits  := 500;
         uf     := uf_ground;
         speed  := 0;
         sr     := 200;
         ucl    := 8;
         r      := 40;
         isbuild:= true;
         max    := 1;
         renerg := 4;
         ctime  := 30;
         ruid   := UID_UVehicleFactory;
         rupgr  := upgr_2tier;
      end;
      if(uid=UID_Mine) then
      begin
         mhits  := 1;
         uf     := uf_ground;
         speed  := 0;
         sr     := 100;
         ucl    := 12;
         r      := 5;
         isbuild:= true;
         solid  := false;
         buff[ub_invis]:=_bufinf;
      end;

      if(uid=UID_UTransport)then
      begin
         mhits  := 700;
         r      := 35;
         uf     := uf_fly;
         speed  := 8;
         sr     := 250;
         ucl    := 21;
         mech   := true;
         apcm   := 30;
         trt    := vid_fps*90;
      end;

      if(uid=UID_USPort) then
      begin
         mhits  := 6000;
         r      := 110;
         uf     := uf_ground;
         speed  := 0;
         sr     := 300;
         ucl    := 0;
         isbuild:= true;
         generg := 1;
         anims  := (x+y) mod 2;
         rld_r  := vid_fps*180;
      end;

      if(uid=UID_UCBuild) then
      begin
         mhits  := 5000;
         r      := 110;
         uf     := uf_ground;
         speed  := 0;
         sr     := base_r;
         ucl    := 0;
         isbuild:= true;
         generg := 1;
         anims  := x mod 4;
      end;
      if(uid in [UID_UBaseMil,UID_UBaseCom,UID_UBaseRef,UID_UBaseNuc,UID_UBaseLab,UID_HFortress])then
      begin
         mhits  := 5000;
         uf     := uf_ground;
         sr     := base_r;
         ucl    := 0;
         r      := 88;
         generg := 2;
         isbuild:= true;
      end;
      if(uid=UID_UBaseGen) then
      begin
         mhits  := 2000;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 2;
         r      := 60;
         generg := 2;
         isbuild:= true;
      end;

      if(uid=UID_Portal)then
      begin
         mhits  := 10000;
         uf     := uf_ground;
         sr     := base_r;
         ucl    := 15;
         r      := 110;
         generg := 1;
         isbuild:= true;
         solid  := false;
         rld_a  := 0;
         rld_r  := vid_fps;
      end;

      _shcf:=mhits/_mms;

      if(ar =0)then ar :=sr;

      if(ctime>0)then bld_s:=(mhits div 2) div ctime;

      if(isbuild)then
      begin
         if(ucl=1)then inc(uo_y,r+12);
         mech:= true;
      end;

      {$IFDEF _FULLGAME}
      if(isbuild)
      then mmr   :=round(r*map_mmcx)
      else shadow:=1+(uf*fly_height);

      _fr:=(r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
      _unit_fsrclc(u);
      {$ENDIF}

      if(onlySVCode)then hits:=mhits;
   end;
end;

procedure initUnits;
var i:byte;
begin
   FillChar(_ulst,sizeof(_ulst),0);
   for i:=0 to 255 do
   begin
      _ulst[i].uid:=i;
      _unit_sclass(@_ulst[i]);
   end;
end;

procedure _setUPGR(rc,upcl,stime,cnt,enrg:integer;rupgr,ruid:byte);
begin
   upgrade_time [rc,upcl]:=vid_fps*stime;
   upgrade_cnt  [rc,upcl]:=cnt;
   _pne_r       [rc,upcl]:=enrg;
   upgrade_rupgr[rc,upcl]:=rupgr;
   upgrade_ruid [rc,upcl]:=ruid;
   upgrade_mfrg [rc,upcl]:=upcl in upgr_1[rc];
end;

procedure ObjTbl;
begin
   FillChar(upgrade_time ,SizeOf(upgrade_time ),0);
   FillChar(upgrade_cnt  ,SizeOf(upgrade_cnt  ),1);
   FillChar(upgrade_rupgr,SizeOf(upgrade_rupgr),0);
   FillChar(upgrade_rupgr,SizeOf(upgrade_ruid ),0);
                              // time lvl enr rupgr ruid
   _setUPGR(r_hell,upgr_attack    ,180,4 ,4 ,255,255);
   _setUPGR(r_hell,upgr_armor     ,180,4 ,4 ,255,255);
   _setUPGR(r_hell,upgr_build     ,120,4 ,4 ,255,255);
   _setUPGR(r_hell,upgr_melee     ,60 ,3 ,3 ,255,255);
   _setUPGR(r_hell,upgr_regen     ,120,2 ,3 ,255,255);
   _setUPGR(r_hell,upgr_pains     ,60 ,4 ,2 ,255,255);
   _setUPGR(r_hell,upgr_vision    ,120,3 ,3 ,255,255);
   _setUPGR(r_hell,upgr_towers    ,120,3 ,3 ,255,255);
   _setUPGR(r_hell,upgr_5bld      ,120,3 ,2 ,255,255);
   _setUPGR(r_hell,upgr_mainm     ,180,1 ,3 ,255,255);
   _setUPGR(r_hell,upgr_paina     ,120,2 ,3 ,255,255);
   _setUPGR(r_hell,upgr_mainr     ,120,2 ,2 ,255,255);
   _setUPGR(r_hell,upgr_pinkspd   ,60 ,1 ,3 ,255,255);
   _setUPGR(r_hell,upgr_misfst    ,120,1 ,2 ,255,255);
   _setUPGR(r_hell,upgr_6bld      ,20 ,15,8 ,255,UID_HMonastery);
   _setUPGR(r_hell,upgr_2tier     ,180,1 ,10,255,UID_HMonastery);
   _setUPGR(r_hell,upgr_revtele   ,120,1 ,3 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_revmis    ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_totminv   ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_bldrep    ,120,3 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_b478tel   ,30 ,15,1 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_hinvuln   ,180,3 ,10,upgr_2tier,UID_HAltar    );
   _setUPGR(r_hell,upgr_bldenrg   ,180,4 ,4 ,upgr_2tier,UID_HAltar    );

   _setUPGR(r_uac ,upgr_attack    ,180,4 ,4 ,255,255);
   _setUPGR(r_uac ,upgr_armor     ,120,5 ,4 ,255,255);
   _setUPGR(r_uac ,upgr_build     ,180,4 ,4 ,255,255);
   _setUPGR(r_uac ,upgr_melee     ,60 ,3 ,3 ,255,255);
   _setUPGR(r_uac ,upgr_mspeed    ,60 ,2 ,3 ,255,255);
   _setUPGR(r_uac ,upgr_plsmt     ,120,2 ,2 ,255,255);
   _setUPGR(r_uac ,upgr_vision    ,120,1 ,3 ,255,255);
   _setUPGR(r_uac ,upgr_towers    ,120,3 ,3 ,255,255);
   _setUPGR(r_uac ,upgr_5bld      ,120,3 ,2 ,255,255);
   _setUPGR(r_uac ,upgr_mainm     ,180,1 ,3 ,255,255);
   _setUPGR(r_uac ,upgr_ucomatt   ,180,1 ,4 ,upgr_mainm,255);
   _setUPGR(r_uac ,upgr_mainr     ,120,2 ,2 ,255,255);
   _setUPGR(r_uac ,upgr_mines     ,60 ,1 ,2 ,255,255);
   _setUPGR(r_uac ,upgr_minesen   ,60 ,1 ,2 ,upgr_mines,255);
   _setUPGR(r_uac ,upgr_6bld      ,180,1 ,8 ,255,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_2tier     ,180,1 ,8 ,255,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_blizz     ,180,8 ,10,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mechspd   ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mecharm   ,180,4 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_6bld2     ,120,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_turarm    ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_rturrets  ,180,1 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_bldenrg   ,180,2 ,4 ,upgr_2tier,UID_UVehicleFactory);


   FillChar(cl2uid,SizeOf(cl2uid),0);

   cl2uid[r_hell,true ,0 ]:=UID_HKeep;
   cl2uid[r_hell,true ,1 ]:=UID_HGate;
   cl2uid[r_hell,true ,2 ]:=UID_HSymbol;
   cl2uid[r_hell,true ,3 ]:=UID_HPools;
   cl2uid[r_hell,true ,4 ]:=UID_HTower;
   cl2uid[r_hell,true ,5 ]:=UID_HTeleport;
   cl2uid[r_hell,true ,6 ]:=UID_HMonastery;
   cl2uid[r_hell,true ,7 ]:=UID_HTotem;
   cl2uid[r_hell,true ,8 ]:=UID_HAltar;
   cl2uid[r_hell,true ,9 ]:=UID_HMilitaryUnit;
   cl2uid[r_hell,true ,12]:=UID_HEye;

   cl2uid[r_hell,false,0 ]:=UID_LostSoul;
   cl2uid[r_hell,false,1 ]:=UID_Imp;
   cl2uid[r_hell,false,2 ]:=UID_Demon;
   cl2uid[r_hell,false,3 ]:=UID_Cacodemon;
   cl2uid[r_hell,false,4 ]:=UID_Baron;
   cl2uid[r_hell,false,5 ]:=UID_Cyberdemon;
   cl2uid[r_hell,false,6 ]:=UID_Mastermind;
   cl2uid[r_hell,false,7 ]:=UID_Pain;
   cl2uid[r_hell,false,8 ]:=UID_Revenant;
   cl2uid[r_hell,false,9 ]:=UID_Mancubus;
   cl2uid[r_hell,false,10]:=UID_Arachnotron;
   cl2uid[r_hell,false,11]:=UID_Archvile;

   cl2uid[r_hell,false,12]:=UID_ZFormer;
   cl2uid[r_hell,false,13]:=UID_ZSergant;
   cl2uid[r_hell,false,14]:=UID_ZCommando;
   cl2uid[r_hell,false,15]:=UID_ZBomber;
   cl2uid[r_hell,false,16]:=UID_ZMajor;
   cl2uid[r_hell,false,17]:=UID_ZBFG;

   cl2uid[r_uac ,true ,0 ]:=UID_UCommandCenter;
   cl2uid[r_uac ,true ,1 ]:=UID_UMilitaryUnit;
   cl2uid[r_uac ,true ,2 ]:=UID_UGenerator;
   cl2uid[r_uac ,true ,3 ]:=UID_UWeaponFactory;
   cl2uid[r_uac ,true ,4 ]:=UID_UTurret;
   cl2uid[r_uac ,true ,5 ]:=UID_URadar;
   cl2uid[r_uac ,true ,6 ]:=UID_UVehicleFactory;
   cl2uid[r_uac ,true ,7 ]:=UID_UPTurret;
   cl2uid[r_uac ,true ,8 ]:=UID_URocketL;
   cl2uid[r_uac ,true ,9 ]:=UID_UCBuild;
   cl2uid[r_uac, true ,12]:=UID_Mine;

   cl2uid[r_uac ,false,0 ]:=UID_Engineer;
   cl2uid[r_uac ,false,1 ]:=UID_Medic;
   cl2uid[r_uac ,false,2 ]:=UID_Sergant;
   cl2uid[r_uac ,false,3 ]:=UID_Commando;
   cl2uid[r_uac ,false,4 ]:=UID_Bomber;
   cl2uid[r_uac ,false,5 ]:=UID_Major;
   cl2uid[r_uac ,false,6 ]:=UID_BFG;
   cl2uid[r_uac ,false,7 ]:=UID_FAPC;
   cl2uid[r_uac ,false,8 ]:=UID_APC;
   cl2uid[r_uac ,false,9 ]:=UID_Terminator;
   cl2uid[r_uac ,false,10]:=UID_Tank;
   cl2uid[r_uac ,false,11]:=UID_Flyer;

   cl2uid[r_uac ,false,21]:=UID_UTransport;

   initUnits;
   {$IFDEF _FULLGAME}
   InitFogR;
   {$ENDIF}
end;


