
{const

// Primary Priority
aipr_nothing          = 0;
aipr_BuilderMoveTech  = 1;
aipr_BuildTowers      = 2;
aipr_BuildEnergy      = 3;
aipr_SelfDestroy      = 4; // ????????
aipr_BuildUnitProd    = 5;
aipr_BuildUpgrProd    = 6;  }

{aipt_unit          = 1;
aipt_building      = 2;
aipt_upgrade       = 3;
aipt_ability       = 4;

var
ai_PrimaryType,
ai_PrimaryID       : byte;
ai_PrimaryEnergy,
ai_PrimaryHellPower,
ai_PrimaryUACLoot  : integer;  }


procedure ai_Builder(pu:PTUnit);
var
build_uid:byte;
procedure SetTowers;
begin
   if(build_uid>0)then exit;

   if(ai_need_Towers<=ai_curr_Towers)then exit;


end;
procedure SetGenerators;
begin
   if(build_uid>0)then exit;

   if(ai_need_Towers<=ai_curr_Towers)then exit;


end;

begin
   build_uid:=0;

   with pu^  do
   with player^ do
   begin
      // requirements in this time
      ai_need_Energy:=400+ai_curr_UnitProds*600;
      if(aip_MaxBarracks>0)then
      begin
         ai_need_UnitProds:=(res_energyl_max div 400);
         if(ai_need_UnitProds<1)then ai_need_UnitProds:=1;
         if(ai_need_UnitProds>aip_MaxBarracks)then ai_need_UnitProds:=aip_MaxBarracks;
      end;

      if(aip_MaxForges>0)then
      begin
         ai_need_UpgrProds:=(res_energyl_max div 1000);
         if(ai_need_UpgrProds>aip_MaxForges)then ai_need_UpgrProds:=aip_MaxForges;
      end;

      if(aip_MaxTowers>0)then
      begin

      end;

      // Define UID to build

      if((aip_flags and aif_base_smart_order)>0)then
      begin
         SetTowers;
      end
      else ;

   end;
end;

procedure ai_PrimaryPriority(pu:PTUnit);
begin

   {
   ai_need_Energy,
   ai_need_Builders,
   ai_need_UnitProds,
   ai_need_UpgrProds,
   ai_need_Towers
   }
end;

procedure ai_Local_Code(pu:PTUnit);
begin
   with pu^  do
     if(ai_alarm_d<NOTSET)then
     begin
        aiu_alarm_d:=ai_alarm_d;
        aiu_alarm_x:=ai_alarm_x;
        aiu_alarm_y:=ai_alarm_y;
     end;
   //if(pu^.isselected)then writeln(ai_inprogress_auid);
end;

procedure ai_Global_Code(pu:PTUnit);
begin
   with pu^     do
   with uid^    do
   with player^ do
   begin
      // units_builders_e
     // units_builders_ec
    { ai_PrimaryType:=0;
     ai_PrimaryID  :=0;  }

     if(uid_isbuilder)then ai_Builder(pu);

   end;
end;


