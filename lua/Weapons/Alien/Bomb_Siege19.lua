/*

--local orig = Bomb.OnInitialized
function Bomb:OnInitialized()
   -- orig(self)
    PredictedProjectile.OnInitialized(self)
    Bomb.kRadius  =  ConditionalValue( GetHasTech(self, kTechId.GorgeBombBuff), 0.22, 0.2)  --Can't be too bad on perf, right? 
    --Print("%s", Bomb.kRadius) yup it works, dunno how noticeable it is....?
end--if good perf then this is brilliantly simple and effective for perf and (gameplay experimentation!)

*/