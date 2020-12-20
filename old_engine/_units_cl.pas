
{$IFDEF _FULLGAME}


procedure _unit_fsrclc(u:PTUnit);
begin
   with u^ do
   begin
      fsr:=0;
      if(fog_cw>0)then
      begin
         fsr:=srng div fog_cw;
         if(fsr>MFogM)then fsr:=MFogM;
      end;
   end;
end;
{$ENDIF}

{procedure _unit_sclass(u:PTUnit);
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
      isbuilder:=false;
      isbarrack:=false;
      issmith  :=false;

      uid:=@_uids[uidi];

      if(uidi=UID_LostSoul)then
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
      if(uidi=UID_Imp) then
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
      if(uidi=UID_Demon) then
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
         apcs   := 2;
      end;
      if(uidi=UID_CacoDemon)then
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
         apcs   := 2;
      end;
      if(uidi=UID_Baron)then
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
         apcs   := 3;
      end;
      if(uidi=UID_Cyberdemon)then
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
         apcs   := 10;
      end;
      if(uidi=UID_Mastermind) then
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
         apcs   := 10;
      end;
      if(uidi=UID_Pain)then
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
         apcs   := 2;
      end;
      if(uidi=UID_Revenant) then
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
         apcs   := 1;
      end;
      if(uidi=UID_Mancubus) then
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
         apcs   := 4;
      end;
      if(uidi=UID_Arachnotron) then
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
         trt    := vid_fps*50;
         renerg := 6;
         ruid   := UID_HMonastery;
         rupgr  := upgr_2tier;
         apcs   := 4;
      end;
      if(uidi=UID_ArchVile) then
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
         apcs   := 2;
      end;

      if(uidi=UID_HKeep)then
      begin
         mhits  := 3000;
         uf     := uf_ground;
         sr     := base_rA[0];
         r      := 66;
         generg := 6;
         isbuild:= true;
         renerg := 8;
         ctime  := 80;
         isbuilder:=true;
      end;
      if(uidi=UID_HGate) then
      begin
         mhits  := 1500;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 1;
         r      := 60;
         generg := 0;
         isbuild:= true;
         rld_a  := 12;
         renerg := 4;
         ctime  := 40;
         isbarrack:=true;
      end;
      if(uidi=UID_HSymbol) then
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
      if(uidi=UID_HPools) then
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
         issmith:= true;
      end;
      if(uidi=UID_HTower) then
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
      if(uidi=UID_HTeleport) then
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
         ctime  := 30;
      end;
      if(uidi=UID_HMonastery)then
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
      if(uidi=UID_HTotem) then
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
      if(uidi=UID_HAltar) then
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
      if(uidi=UID_HFortress) then
      begin
         mhits  := 4000;
         uf     := uf_ground;
         sr     := 300;
         ucl    := 9;
         r      := 86;
         isbuild:= true;
         max    := 1;
         renerg := 10;
         generg := 4;
         ctime  := 90;
         ruid   := UID_HPools;
         isbuilder:=true;
      end;
      if(uidi=UID_HEye) then
      begin
         mhits  := 240;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 21;
         r      := 10;
         isbuild:= true;
         buff[ub_detect]:=_bufinf;
         rld_a  := vid_fps;
         ctime  := 0;
         bld_s  := 0;
      end;

////////////////////////////////////////////////////////////////////////////////

      if(uidi in [UID_Engineer,UID_ZEngineer])then
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
         trt    := vid_fps*10;
         renerg := 1;
         arf    :=(sr div 4)*3;
         if(uidi=UID_ZEngineer)then
         begin
            painc  := 3;
            ucl    := 13;
            speed  := 16;
            anims  := 22;
            rld_a  := 0;
            trt    := vid_fps*15;
            //ruid   := UID_HMilitaryUnit;
         end;
      end;
      if(uidi in [UID_Medic,UID_ZFormer])then
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
         trt    := vid_fps*10;
         renerg := 1;
         if(uidi=UID_ZFormer)then
         begin
            painc  := 3;
            ucl    := 12;
            speed  := 10;
            anims  := 14;
            rld_a  := 22;
            trt    := vid_fps*5;
            //ruid   := UID_HMilitaryUnit;
         end;
         arf    :=(sr div 4)*3;
      end;
      if(uidi in [UID_Sergant,UID_ZSergant])then
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
         if(uidi=UID_ZSergant)then
         begin
            painc  := 3;
            ucl    := 14;
            speed  := 10;
            anims  := 14;
            //ruid   := UID_HMilitaryUnit;
         end;
         arf    :=(sr div 4)*3;
      end;
      if(uidi in [UID_Commando,UID_ZCommando])then
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
         if(uidi=UID_ZCommando)then
         begin
            painc  := 3;
            ucl    := 15;
            rld_r  := 10;
            //ruid   := UID_HMilitaryUnit;
         end;
         arf    :=220;
      end;
      if(uidi in [UID_Bomber,UID_ZBomber])then
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
         if(uidi=UID_ZBomber)then
         begin
            painc  := 3;
            ucl    := 16;
            //ruid   := UID_HMilitaryUnit;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uidi in [UID_Major,UID_ZMajor])then
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
         if(uidi=UID_ZMajor)then
         begin
            painc  := 3;
            ucl    := 17;
            //ruid   := UID_HMilitaryUnit;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uidi in [UID_BFG,UID_ZBFG])then
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
         if(uidi=UID_ZBFG)then
         begin
            painc  := 3;
            ucl    := 18;
            //ruid   := UID_HMilitaryUnit;
         end
         else
         ruid   := UID_UWeaponFactory;
      end;
      if(uidi=UID_FAPC)then
      begin
         mhits  := 250;
         r      := 33;
         uf     := uf_fly;
         speed  := 22;
         sr     := 250;
         ucl    := 7;
         mech   := true;
         apcm   := 10;
         rld_r  := 30;
         trt    := vid_fps*25;
         renerg := 3;
         ruid   := UID_UWeaponFactory;
      end;
      if(uidi=UID_APC)then
      begin
         mhits  := 400;
         r      := 25;
         uf     := uf_ground;
         speed  := 15;
         sr     := 250;
         ucl    := 8;
         mech   := true;
         apcm   := 4;
         apcs   := 8;
         anims  := 17;
         rld_r  := 30;
         trt    := vid_fps*25;
         renerg := 3;
         ruid   := UID_UWeaponFactory;
      end;
      if(uidi=UID_Terminator)then
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
      if(uidi=UID_Tank)then
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
      if(uidi=UID_Flyer)then
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


      if(uidi in [UID_UCommandCenter,UID_HCommandCenter])then
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
         ctime  := 80;
         rld_r  := 30;
         apcm   := 20;
         isbuilder:=true;
         if(uidi=UID_HCommandCenter)then
         begin
            ucl :=12;
            apcm :=30;
            rld_r:=45;
         end;
      end;
      if(uidi in [UID_UMilitaryUnit,UID_HMilitaryUnit])then
      begin
         mhits  := 1700;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 1;
         r      := 66;
         isbuild:= true;
         renerg := 4;
         ctime  := 40;
         isbarrack:=true;

         if(uidi=UID_HMilitaryUnit)then
         begin
            ucl :=13;
         end;
      end;
      if(uidi=UID_UGenerator) then
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
      if(uidi=UID_UWeaponFactory) then
      begin
         mhits  := 1700;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 3;
         r      := 62;
         isbuild:= true;
         renerg := 6;
         ctime  := 40;
         issmith:=true;
      end;
      if(uidi=UID_UTurret) then
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
      if(uidi=UID_URadar) then
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
      if(uidi=UID_UVehicleFactory) then
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
      if(uidi=UID_UPTurret) then
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
         ruid   := UID_UVehicleFactory;
      end;
      if(uidi=UID_URocketL) then
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
      if(uidi=UID_URTurret) then
      begin
         mhits  := 500;
         uf     := uf_ground;
         sr     := 250;
         ucl    := 10;
         r      := 17;
         isbuild:= true;
         rld_r  := 90;
         rld_a  := 0;
         anims  := 2;
         renerg := 4;
         ctime  := 30;
         ruid   := UID_UVehicleFactory;
         rupgr  := upgr_rturrets;
         arf    := (sr div 5)*4;
      end;
      if(uidi=UID_UNuclearPlant) then
      begin
         mhits  := 2000;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 9;
         r      := 70;
         isbuild:= true;
         max    := 1;
         renerg := 10;
         generg := 10;
         ctime  := 90;
         ruid   := UID_UWeaponFactory;
      end;

      if(uidi=UID_UMine) then
      begin
         mhits  := 1;
         uf     := uf_ground;
         speed  := 0;
         sr     := 100;
         ucl    := 21;
         r      := 5;
         isbuild:= true;
         solid  := false;
         buff[ub_invis]:=_bufinf;
         ctime  :=0;
         bld_s  :=0;
      end;

      if(uidi=UID_UTransport)then
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

      if(uidi=UID_USPort) then
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

      if(uidi=UID_UCBuild) then
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
      if(uidi in [UID_UBaseMil,UID_UBaseCom,UID_UBaseRef,UID_UBaseNuc,UID_UBaseLab])then
      begin
         mhits  := 5000;
         uf     := uf_ground;
         sr     := base_r;
         ucl    := 0;
         r      := 88;
         generg := 2;
         isbuild:= true;
      end;
      if(uidi=UID_UBaseGen) then
      begin
         mhits  := 2000;
         uf     := uf_ground;
         sr     := 200;
         ucl    := 2;
         r      := 60;
         generg := 4;
         renerg := 2;
         isbuild:= true;
      end;

      if(uidi=UID_UPortal)then
      begin
         mhits  := 20000;
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

      if(ctime>0)then
      begin
         bld_s:=(mhits div 2) div ctime;

      end;
      if(bld_s<=0)then bld_s:=1;

      if(isbuild)then
      begin
         if(isbarrack)then inc(uo_y,r+12);
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
end;  }

procedure _unit_apUID(pu:PTUnit);
begin
   with pu^ do
   begin
      uid:=@_uids[uidi];
      with uid^ do
      begin
         r     := _r;
         srng  := _srng;
         speed := _speed;
         uf    := _uf;
         apcm  := _apcm;
         solid := _issolid;
         mmr   := 1;

         if(_isbuilding)and(_isbarrack)then inc(uo_y,r+12);

         {$IFDEF _FULLGAME}
         if(_isbuilding)
         then mmr   :=round(r*map_mmcx)
         else shadow:=1+(uf*fly_height);

         _unit_fsrclc(pu);
         {$ENDIF}
         if(onlySVCode)then hits:=_mhits;
      end;
   end;
end;

procedure initUIDS;
var i:byte;
begin
   for i:=0 to 255 do
   with _uids[i] do
   begin
      _mhits     := 100;
      _max       := 32000;
      _btime     := 1;
      _uf        := uf_ground;
      _ucl       := 255;
      _apcs      := 1;
      _urace     := r_hell;

      _isbuilding:=false;
      _isbuilder :=false;
      _issmith   :=false;
      _isbarrack :=false;
      _ismech    :=false;
      _issolid   :=true;

      case i of
//         HELL BUILDINGS   ////////////////////////////////////////////////////
UID_HKeep:
begin
   _mhits     := 3000;
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 0;
   _btime     := 75;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:= [UID_HKeep..UID_HFortress];
end;
UID_HGate:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 60;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 40;

   _isbuilding:= true;
   _isbarrack := true;

   ups_units  := [UID_LostSoul..UID_Archvile];
end;
UID_HSymbol:
begin
   _mhits     := 200;
   _renerg    := 1;
   _generg    := 1;
   _r         := 24;
   _srng      := 200;
   _ucl       := 2;
   _btime     := 10;

   _isbuilding:= true;
end;
UID_HPools:
begin
   _mhits     := 1000;
   _renerg    := 6;
   _r         := 53;
   _srng      := 200;
   _ucl       := 3;
   _btime     := 40;

   _isbuilding:= true;
   _issmith   := true;
end;
UID_HTower:
begin
   _mhits     := 700;
   _renerg    := 2;
   _r         := 21;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 20;

   _isbuilding:= true;
end;
UID_HTeleport:
begin
   _mhits     := 400;
   _renerg    := 4;
   _r         := 28;
   _srng      := 200;
   _ucl       := 5;
   _btime     := 30;
   _max       := 1;

   _isbuilding:= true;
end;
UID_HMonastery:
begin
   _mhits     := 1000;
   _renerg    := 10;
   _r         := 65;
   _srng      := 200;
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

   _isbuilding:= true;
end;
UID_HTotem:
begin
   _mhits     := 700;
   _renerg    := 3;
   _r         := 21;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 25;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HAltar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 50;
   _srng      := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;

   _isbuilding:= true;
end;
UID_HFortress:
begin
   _mhits     := 4000;
   _renerg    := 10;
   _generg    := 4;
   _r         := 86;
   _srng      := 300;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_HPools;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:=[UID_HKeep..UID_HAltar]-[UID_HFortress];
end;
UID_HEye:
begin
   _mhits     := 240;
   _renerg    := 1;
   _r         := 5;
   _srng      := 250;
   _ucl       := 21;
   _btime     := 1;
   //_rupgr     := upgr_vision;

   _isbuilding:= true;
   _issolid   := false;
end;
UID_HCommandCenter:  //UID_UCommandCenter
begin
   _mhits     := 3000;
   _renerg    := 8;
   _generg    := 6;
   _speed     := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 12;
   _btime     := 90;

   _isbuilding:= true;

   ups_builder:=[UID_HCommandCenter,UID_HSymbol,UID_HTower,UID_HMilitaryUnit];
   ups_apc    :=demons;
end;
UID_HMilitaryUnit:
begin
   _mhits     := 1500;
   _renerg    := 4;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 13;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units  :=zimbas;
end;
//////////////////////////////

UID_LostSoul   :
begin
   _mhits     := 90;
   _renerg    := 1;
   _r         := 10;
   _speed     := 23;
   _srng      := 250;
   _ucl       := 0;
   _painc     := 1;
   _btime     := 8;
   _uf        := uf_soaring;
end;
UID_Imp        :
begin
   _mhits     := 70;
   _renerg    := 1;
   _r         := 11;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 1;
   _painc     := 3;
   _btime     := 5;
end;
UID_Demon      :
begin
   _mhits     := 150;
   _renerg    := 2;
   _r         := 14;
   _speed     := 14;
   _srng      := 200;
   _ucl       := 2;
   _painc     := 8;
   _btime     := 8;
end;
UID_Cacodemon  :
begin
   _mhits     := 225;
   _renerg    := 2;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 3;
   _painc     := 6;
   _btime     := 20;
   _apcs      := 2;
end;
UID_Baron      :
begin
   _mhits     := 350;
   _renerg    := 4;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 4;
   _painc     := 8;
   _btime     := 40;
   _apcs      := 3;
end;
UID_Cyberdemon :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 20;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 5;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
end;
UID_Mastermind :
begin
   _mhits     := 2000;
   _renerg    := 10;
   _max       := 1;
   _r         := 35;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 6;
   _painc     := 15;
   _btime     := 90;
   _apcs      := 10;
   _ruid      := UID_HMonastery;
end;
UID_Pain       :
begin
   _mhits     := 200;
   _renerg    := 6;
   _r         := 14;
   _speed     := 9;
   _srng      := 250;
   _ucl       := 7;
   _painc     := 3;
   _btime     := 40;
   _apcs      := 2;
   _ruid      := UID_HFortress;
end;
UID_Revenant   :
begin
   _mhits     := 200;
   _renerg    := 4;
   _r         := 13;
   _speed     := 12;
   _srng      := 250;
   _ucl       := 8;
   _painc     := 7;
   _btime     := 40;
   _ruid      := UID_HFortress;
end;
UID_Mancubus   :
begin
   _mhits     := 400;
   _renerg    := 6;
   _r         := 20;
   _speed     := 6;
   _srng      := 250;
   _ucl       := 9;
   _painc     := 4;
   _btime     := 60;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;
UID_Arachnotron:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 20;
   _speed     := 8;
   _srng      := 250;
   _ucl       := 10;
   _painc     := 4;
   _btime     := 50;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;
UID_Archvile:
begin
   _mhits     := 400;
   _renerg    := 10;
   _r         := 14;
   _speed     := 15;
   _srng      := 250;
   _ucl       := 11;
   _painc     := 12;
   _btime     := 90;
   _apcs      := 2;
   _ruid      := UID_HMonastery;
   //_rupgr     := upgr_2tier;
end;

UID_ZFormer:
begin
   _mhits     := 50;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 250;
   _ucl       := 12;
   _painc     := 1;
   _btime     := 5;
end;
UID_ZEngineer:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 14;
   _srng      := 200;
   _ucl       := 13;
   _painc     := 4;
   _btime     := 20;
end;
UID_ZSergant:
begin
   _mhits     := 80;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srng      := 241;
   _ucl       := 14;
   _painc     := 4;
   _btime     := 10;
end;
UID_ZCommando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 15;
   _painc     := 4;
   _btime     := 15;
end;
UID_ZBomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 16;
   _painc     := 4;
   _btime     := 30;
end;
UID_ZMajor:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 17;
   _painc     := 4;
   _btime     := 20;
end;
UID_ZBFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 18;
   _painc     := 4;
   _btime     := 60;
end;


//         UAC BUILDINGS   /////////////////////////////////////////////////////
UID_UCommandCenter:
begin
   _mhits     := 3500;
   _renerg    := 8;
   _generg    := 6;
   _r         := 66;
   _srng      := base_rA[0];
   _ucl       := 0;
   _btime     := 90;

   _isbuilding:= true;
   _isbuilder := true;

   ups_builder:=[UID_UCommandCenter..UID_UNuclearPlant];
end;
UID_UMilitaryUnit:
begin
   _mhits     := 1750;
   _renerg    := 4;
   _r         := 66;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 40;

   _isbuilding:=true;
   _isbarrack :=true;

   ups_units:=marines+[UID_APC,UID_FAPC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_UGenerator:
begin
   _mhits     := 400;
   _renerg    := 2;
   _generg    := 2;
   _r         := 42;
   _srng      := 200;
   _ucl       := 2;
   _btime     := 20;

   _isbuilding:=true;
end;
UID_UWeaponFactory:
begin
   _mhits     := 1750;
   _renerg    := 6;
   _r         := 62;
   _srng      := 200;
   _ucl       := 3;
   _btime     := 40;

   _isbuilding:=true;
   _issmith   :=true;
end;
UID_UTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 15;

   _isbuilding:=true;
end;
UID_URadar:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 35;
   _srng      := 200;
   _ucl       := 5;
   _btime     := 30;
   _max       := 1;

   _isbuilding:=true;
end;
UID_UVehicleFactory :
begin
   _mhits     := 1750;
   _renerg    := 10;
   _r         := 62;
   _srng      := 200;
   _ucl       := 6;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UWeaponFactory;

   _isbuilding:=true;
end;
UID_UPTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 20;
   _ruid      := UID_UVehicleFactory;

   _isbuilding:=true;
end;
UID_URocketL:
begin
   _mhits     := 500;
   _renerg    := 4;
   _r         := 40;
   _srng      := 200;
   _ucl       := 8;
   _btime     := 30;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _isbuilding:=true;
end;
UID_URTurret:
begin
   _mhits     := 400;
   _renerg    := 2;
   _r         := 17;
   _srng      := 250;
   _ucl       := 10;
   _btime     := 25;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_rturrets;

   _isbuilding:=true;
end;
UID_UNuclearPlant:
begin
   _mhits     := 2000;
   _renerg    := 10;
   _generg    := 10;
   _r         := 70;
   _srng      := 200;
   _ucl       := 9;
   _btime     := 90;
   _max       := 1;
   _ruid      := UID_UVehicleFactory;

   _isbuilding:=true;
end;
UID_UMine:
begin
   _mhits     := 5;
   _renerg    := 1;
   _r         := 5;
   _srng      := 100;
   _ucl       := 21;
   _btime     := 5;
   _ucl       := 9;

   _isbuilding:=true;
   _issolid   := false;
end;

///////////////////////////////////
UID_Engineer:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 200;
   _ucl       := 0;
   _btime     := 10;
end;
UID_Medic:
begin
   _mhits     := 100;
   _renerg    := 1;
   _r         := 12;
   _speed     := 13;
   _srng      := 200;
   _ucl       := 1;
   _btime     := 10;
end;
UID_Sergant:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 13;
   _srng      := 241;
   _ucl       := 2;
   _btime     := 10;
end;
UID_Commando:
begin
   _mhits     := 100;
   _renerg    := 2;
   _r         := 12;
   _speed     := 11;
   _srng      := 250;
   _ucl       := 3;
   _btime     := 15;
end;
UID_Bomber:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 4;
   _btime     := 30;
end;
UID_Major:
begin
   _mhits     := 100;
   _renerg    := 4;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 5;
   _btime     := 20;
end;
UID_BFG:
begin
   _mhits     := 100;
   _renerg    := 5;
   _r         := 12;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 6;
   _btime     := 60;
end;
UID_FAPC:
begin
   _mhits     := 250;
   _renerg    := 3;
   _r         := 33;
   _speed     := 22;
   _srng      := 250;
   _ucl       := 7;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 8;
   _ruid      := UID_UWeaponFactory;

   _ismech    := true;

   ups_apc    :=marines+[UID_APC,UID_Terminator,UID_Tank,UID_Flyer];
end;
UID_APC:
begin
   _mhits     := 350;
   _renerg    := 3;
   _r         := 25;
   _speed     := 15;
   _srng      := 250;
   _ucl       := 8;
   _btime     := 25;
   _apcm      := 10;
   _apcs      := 10;
   _ruid      := UID_UWeaponFactory;

   _ismech    := true;

   ups_apc    :=marines;
end;
UID_Terminator:
begin
   _mhits     := 350;
   _renerg    := 6;
   _r         := 16;
   _speed     := 14;
   _srng      := 275;
   _ucl       := 9;
   _btime     := 60;
   _apcs      := 3;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Tank:
begin
   _mhits     := 400;
   _renerg    := 8;
   _r         := 20;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 10;
   _btime     := 60;
   _apcs      := 7;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_Flyer:
begin
   _mhits     := 350;
   _renerg    := 8;
   _r         := 18;
   _speed     := 19;
   _srng      := 275;
   _ucl       := 11;
   _btime     := 60;
   _apcs      := 7;
   _uf        := uf_fly;
   _ruid      := UID_UVehicleFactory;
   //_rupgr     := upgr_2tier;

   _ismech    := true;
end;
UID_UTransport:
begin
   _mhits     := 400;
   _renerg    := 5;
   _r         := 36;
   _speed     := 10;
   _srng      := 250;
   _ucl       := 12;
   _btime     := 60;
   _apcm      := 30;
   _apcs      := 10;
   _ruid      := UID_UVehicleFactory;

   _ismech    := true;
end;

UID_UBaseMil:
begin
end;
UID_UBaseCom:
begin
end;
UID_UBaseGen:
begin
end;
UID_UBaseRef:
begin
end;
UID_UBaseNuc:
begin
end;
UID_UBaseLab:
begin
end;
UID_UCBuild:
begin
end;
UID_USPort:
begin
end;
UID_UPortal:
begin
end;
      end;

      if(i in uids_hell)then _urace:=r_hell;
      if(i in uids_uac )then _urace:=r_uac;

      _ismech:=_ismech or _isbuilding;

      _shcf:=_mhits/_mms;

      if(_btime >0)then _bstep:=(_mhits div 2) div _btime;
      if(_bstep<=0)then _bstep:=1;
      _tprod:=_btime*fr_fps;

      {$IFDEF _FULLGAME}
      _fr:=(_r div fog_cw)+1;
      if(_fr<1)then _fr:=1;
      {$ENDIF}
   end;
end;

procedure initUnits;
var i:byte;
begin
   FillChar(ui_puids,SizeOf(ui_puids),0);
   FillChar(_uids   ,SizeOf(_uids   ),0);

   initUIDS;

   {for i:=0 to 255 do
    with _uids[i] do
     if(_ucl<=_uts)and(_race>0)then
      if(cl2uid[_race,_isbuilding,_ucl]=0)then cl2uid[_race,_isbuilding,_ucl]:=i; }
end;

procedure _setUPGR(rc,upcl,stime,max,enrg:integer;rupgr,ruid:byte);
begin
   with _upids[upcl] do
   begin
      _up_ruid  := ruid;
      _up_rupgr := rupgr;
      _up_race  := rc;
      _up_time  := stime*fr_fps;
      _up_renerg:= enrg;
      _up_max   := max;
      _up_mfrg  := false;
   end;
end;

procedure ObjTbl;
begin
   FillChar(_upids,SizeOf(_upids),0);
 {  FillChar(upgrade_time ,SizeOf(upgrade_time ),0);
   FillChar(upgrade_cnt  ,SizeOf(upgrade_cnt  ),1);
   FillChar(upgrade_rupgr,SizeOf(upgrade_rupgr),0);
   FillChar(upgrade_rupgr,SizeOf(upgrade_ruid ),0);   }
                              // time lvl enr rupgr     ruid
  { _setUPGR(r_hell,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_armor     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_build     ,120,4 ,4 ,255       ,255);
   _setUPGR(r_hell,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_regen     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_pains     ,60 ,4 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_vision    ,120,3 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_paina     ,120,2 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_pinkspd   ,60 ,1 ,3 ,255       ,255);
   _setUPGR(r_hell,upgr_misfst    ,120,1 ,2 ,255       ,255);
   _setUPGR(r_hell,upgr_6bld      ,20 ,15,8 ,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_2tier     ,180,1 ,10,255       ,UID_HMonastery);
   _setUPGR(r_hell,upgr_revtele   ,120,1 ,3 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_revmis    ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_totminv   ,120,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_bldrep    ,120,3 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_b478tel   ,30 ,15,1 ,upgr_2tier,UID_HMonastery);
   _setUPGR(r_hell,upgr_hinvuln   ,180,3 ,10,upgr_2tier,UID_HAltar    );
   _setUPGR(r_hell,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_HFortress );
   _setUPGR(r_hell,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_HFortress );

   _setUPGR(r_uac ,upgr_attack    ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_armor     ,120,5 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_build     ,180,4 ,4 ,255       ,255);
   _setUPGR(r_uac ,upgr_melee     ,60 ,3 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_mspeed    ,60 ,2 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_plsmt     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_vision    ,120,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_towers    ,120,4 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_5bld      ,120,3 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mainm     ,180,1 ,3 ,255       ,255);
   _setUPGR(r_uac ,upgr_ucomatt   ,180,1 ,4 ,upgr_mainm,255);
   _setUPGR(r_uac ,upgr_mainr     ,120,2 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_mines     ,60 ,1 ,2 ,255       ,255);
   _setUPGR(r_uac ,upgr_minesen   ,60 ,1 ,2 ,upgr_mines,255);
   _setUPGR(r_uac ,upgr_6bld      ,180,1 ,8 ,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_2tier     ,180,1 ,10,255       ,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_blizz     ,180,8 ,10,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mechspd   ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mecharm   ,180,4 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_6bld2     ,120,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_mainonr   ,60 ,1 ,2 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_turarm    ,120,2 ,3 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_rturrets  ,180,1 ,4 ,upgr_2tier,UID_UVehicleFactory);
   _setUPGR(r_uac ,upgr_bldenrg   ,180,3 ,4 ,upgr_2tier,UID_UNuclearPlant  );
   _setUPGR(r_uac ,upgr_9bld      ,180,1 ,4 ,upgr_2tier,UID_UNuclearPlant  );  }

   initUnits;
end;


