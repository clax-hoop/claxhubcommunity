--[[
    CLAX HUB - Slim - discord.gg/clax
    Roblox Luau client UI.
    Review any remote script source before loading it.
]] 
local THEMES={
neonred={name="Neon Red",Bg=Color3.fromRGB(4,4,5),Side=Color3.fromRGB(7,7,8),Card=Color3.fromRGB(11,11,13),CardHi=Color3.fromRGB(18,18,22),Border=Color3.fromRGB(38,38,44),Text=Color3.fromRGB(245,245,250),TextDim=Color3.fromRGB(140,140,150),Accent=Color3.fromRGB(255,35,50),Glow=Color3.fromRGB(255,45,60),Success=Color3.fromRGB(60,220,120),Danger=Color3.fromRGB(255,60,60)},
darkred={name="Dark Red",Bg=Color3.fromRGB(14,10,11),Side=Color3.fromRGB(10,8,9),Card=Color3.fromRGB(22,14,16),CardHi=Color3.fromRGB(32,18,20),Border=Color3.fromRGB(48,36,38),Text=Color3.fromRGB(245,235,235),TextDim=Color3.fromRGB(150,120,125),Accent=Color3.fromRGB(220,30,45),Glow=Color3.fromRGB(220,30,45),Success=Color3.fromRGB(60,200,120),Danger=Color3.fromRGB(230,70,70)},
midnight={name="Midnight",Bg=Color3.fromRGB(4,6,12),Side=Color3.fromRGB(6,8,14),Card=Color3.fromRGB(11,15,24),CardHi=Color3.fromRGB(17,23,34),Border=Color3.fromRGB(38,44,60),Text=Color3.fromRGB(235,240,250),TextDim=Color3.fromRGB(120,140,170),Accent=Color3.fromRGB(80,140,255),Glow=Color3.fromRGB(80,140,255),Success=Color3.fromRGB(60,200,120),Danger=Color3.fromRGB(230,70,70)}}
local C=THEMES.neonred
local CONFIG={
    Width=540,Height=380,TopH=44,SideW=142,
    Logo="rbxassetid://98840025913034",
    Background="rbxassetid://120278616307495",
    Discord="https://discord.gg/clax",
    MainTrans=0.25,SideTrans=0.35,ContentTrans=0.4,CardTrans=0.15,
    MasterVolume=0.6
}
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local Stats=game:GetService("Stats")
local RunService=game:GetService("RunService")
local SoundService=game:GetService("SoundService")
local GENV=(getgenv and getgenv()) or _G
if GENV.CLAX_CONNS then
    for _,c in ipairs(GENV.CLAX_CONNS) do pcall(function() c:Disconnect() end) end
end
GENV.CLAX_CONNS={}
local function trackConn(c) table.insert(GENV.CLAX_CONNS,c);return c end
local parentGui=game:GetService("CoreGui")
pcall(function() if gethui then parentGui=gethui() end end)
pcall(function()
    local ok,children=pcall(function() return parentGui:GetChildren() end)
    if ok and children then
        for _,v in pairs(children) do
            if v.Name=="CLAXHUB" or v.Name=="CLAXHUB_Loader" then v:Destroy() end
        end
    end
end)
local httpRequest=(syn and syn.request) or (http and http.request) or http_request or request
local function safeHttpGet(url)
    if type(url)~="string" or not url:match("^https://") then return nil end
    if httpRequest then
        local ok,res=pcall(httpRequest,{Url=url,Method="GET"})
        if ok and type(res)=="table" and type(res.Body)=="string" and #res.Body>20 then
            if not res.Body:find("404: Not Found",1,true) and not res.Body:find("<html",1,true) then return res.Body end
        end
    end
    local ok,res=pcall(game.HttpGet,game,url)
    if ok and type(res)=="string" and #res>20 and not res:find("404: Not Found",1,true) and not res:find("<html",1,true) then return res end
    return nil
end
local ScriptCache={}
local ScriptCacheOrder={}
local SCRIPT_CACHE_MAX=40
local function tryFetch(urls)
    for _,u in ipairs(urls) do
        if ScriptCache[u] then return ScriptCache[u] end
        local r=safeHttpGet(u)
        if r and #r>=40 then
            ScriptCache[u]=r
            table.insert(ScriptCacheOrder,u)
            while #ScriptCacheOrder>SCRIPT_CACHE_MAX do
                local old=table.remove(ScriptCacheOrder,1)
                ScriptCache[old]=nil
            end
            return r
        end
    end
    return nil
end
local StateFile="claxhub_state.json"
local State={theme="neonred",lang="tr",activeTab="home",autoExec={},soundOn=true,stats={scriptsLoaded=0,sessions=0},settings={masterVolume=0.6,animations=true,notifications=true},favorites={},history={},notifications={},sessionStart=0}
pcall(function()
    if isfile and isfile(StateFile) then
        local d=HttpService:JSONDecode(readfile(StateFile))
        for k,v in pairs(d) do State[k]=v end
    end
end)
local function saveState() pcall(function() if writefile then writefile(StateFile,HttpService:JSONEncode(State)) end end) end
if type(State.stats)~="table" then State.stats={} end
State.stats.scriptsLoaded=tonumber(State.stats.scriptsLoaded) or 0
if type(State.autoExec)~="table" then State.autoExec={} end
if type(State.settings)~="table" then State.settings={} end
if type(State.favorites)~="table" then State.favorites={} end
if type(State.history)~="table" then State.history={} end
if type(State.notifications)~="table" then State.notifications={} end
if not THEMES[State.theme] then State.theme="neonred" end
if not (State.lang=="tr" or State.lang=="en") then State.lang="tr" end
State.stats.sessions=(tonumber(State.stats.sessions) or 0)+1
State.settings=State.settings or {}
State.settings.masterVolume=tonumber(State.settings.masterVolume) or 0.6
State.settings.animations=State.settings.animations~=false
State.settings.notifications=State.settings.notifications~=false
State.favorites=State.favorites or {}
State.history=State.history or {}
State.notifications=State.notifications or {}
if not State.lang then State.lang="tr" end
State.sessionStart=os.clock()
local IS_FIRST_SESSION=(State.stats.sessions==1)
CONFIG.MasterVolume=State.settings.masterVolume
saveState()
if THEMES[State.theme] then C=THEMES[State.theme] end
local L={
tr={title="CLAX HUB",search="Ara...",tabHome="Ana Sayfa",tabFavorites="Favoriler",tabPlayers="Oyuncular",tabSAE="Steal An Egg",tabMM2="MM2",tabBLOX="Blox Fruits",tabBASE="Break & Steal Egg",tabRIDE="Ride a Pet",tabShader="Shaders",tabServer="Server Hop",tabAnim="Animation",tabConsole="Konsol",tabAbout="Hakkında",infoSystem="System",infoCommunity="Community",infoCredits="Credits",infoGuide="Guide",welcome="Merhaba,",subtitle="CLAX HUB",sysTitle="SİSTEM BİLGİSİ",fps="FPS",ping="Ping",executor="Executor",game="Oyun",server="Sunucu",clock="Saat",statsTitle="OTURUM İSTATİSTİKLERİ",sessions="OTURUMLAR",loaded="YÜKLENEN",favCount="FAVORİ",duration="SÜRE",copyDiscord="DISCORD DAVETİ KOPYALA",copyDiscordSub="CLAX HUB Discord davet linkini panoya kopyala",load="Yükle",loading="...",okText="OK",errorText="HATA",favEmpty="Henüz favori script yok.\nScript kartlarındaki * butonuna bas.",sectionGames="OYUNLAR",sectionTools="ARAÇLAR",playersTitle="OYUNCULAR",teleport="Işınla",teleported="-> ışınlandı",consoleTitle="SİSTEM KAYITLARI",clear="Temizle",about="Hakkında",credits="Credits",community="Community",guide="Quick Guide",theme="Tema",loadingTitle="CLAX HUB YÜKLENİYOR",aboutBody="CLAX HUB, Roblox'ta işine yarayan scriptleri tek çatı altında toplar.\n\nAmacımız basit: dağınık GitHub repolarında, ölü Discord davetlerinde, yarım kalmış loader'larda kaybolmak yok.\n\nKataloğumuzdaki her script test edilmiş, çalıştığı onaylanmış halde sunulur.\n\nSen sadece seç ve yükle. Gerisini biz hallederiz.",creditsBody="Kurucu:      clax\nGeliştirici:  clax",communityBody="CLAX HUB bir topluluktur.\n\nGerisi Discord sunucumuzda:\n\n  > Script önerisi ve istek kanalı\n  > Hata bildirimi ve teknik destek\n  > Güncelleme duyuruları\n  > Genel sohbet ve muhabbet\n\ndiscord.gg/clax",guideBody="1.  Sol menüden kategori seç\n2.  'Yükle' butonuna bas\n3.  Favorilere eklemek için * bas\n4.  Otomatik yükleme için A'ya bas\n5.  RightShift veya Insert ile hub'ı aç/kapat\n6.  Arama kutusu ile script ara",toastLoaded="yüklendi",toastError="hata",toastFavAdded="* Favorilere eklendi",toastFavReset="Favoriler sıfırlandı",toastHistoryCleared="Geçmiş temizlendi",toastCopied="discord.gg/clax kopyalandı",toastReady="CLAX HUB hazır",toastTheme="Tema:",toastAuto="Auto:",toastLangSwitch="Dil: Türkçe",langBtn="TR"},
en={title="CLAX HUB",search="Search...",tabHome="Home",tabFavorites="Favorites",tabPlayers="Players",tabSAE="Steal An Egg",tabMM2="MM2",tabBLOX="Blox Fruits",tabBASE="Break & Steal Egg",tabRIDE="Ride a Pet",tabShader="Shaders",tabServer="Server Hop",tabAnim="Animation",tabConsole="Console",tabAbout="About",infoSystem="System",infoCommunity="Community",infoCredits="Credits",infoGuide="Guide",welcome="Hello,",subtitle="CLAX HUB",sysTitle="SYSTEM INFO",fps="FPS",ping="Ping",executor="Executor",game="Game",server="Server",clock="Clock",statsTitle="SESSION STATS",sessions="SESSIONS",loaded="LOADED",favCount="FAVS",duration="UPTIME",copyDiscord="COPY DISCORD INVITE",copyDiscordSub="Copy the CLAX HUB Discord invite to clipboard",load="Load",loading="...",okText="OK",errorText="ERROR",favEmpty="No favorites yet.\nPress * on any script card.",sectionGames="GAMES",sectionTools="TOOLS",playersTitle="PLAYERS",teleport="Teleport",teleported="-> teleported",consoleTitle="SYSTEM LOGS",clear="Clear",about="About",credits="Credits",community="Community",guide="Quick Guide",theme="Theme",loadingTitle="CLAX HUB LOADING",aboutBody="CLAX HUB gathers useful Roblox scripts under one roof.\n\nOur goal is simple: no more digging through scattered GitHub repos, dead Discord invites, or half-broken loaders.\n\nEvery script in our catalog is tested and confirmed working.\n\nYou just pick and load. We handle the rest.",creditsBody="Founder:     clax\nDeveloper:   clax",communityBody="CLAX HUB is a community.\n\nThe rest is on our Discord:\n\n  > Script suggestions and requests\n  > Bug reports and support\n  > Announcements and updates\n  > General chat\n\ndiscord.gg/clax",guideBody="1.  Pick a category from the sidebar\n2.  Hit the 'Load' button\n3.  Press * to favorite\n4.  Press A for auto-load\n5.  RightShift or Insert to toggle the hub\n6.  Use the search box",toastLoaded="loaded",toastError="error",toastFavAdded="* Added to favorites",toastFavReset="Favorites cleared",toastHistoryCleared="History cleared",toastCopied="discord.gg/clax copied",toastReady="CLAX HUB ready",toastTheme="Theme:",toastAuto="Auto:",toastLangSwitch="Language: English",langBtn="EN"}}
local function T() return L[State.lang] or L.tr end
local langQueue={}
local function registerLang(fn) table.insert(langQueue,fn) end
local function applyLang(key)
    if not L[key] then return end
    State.lang=key;saveState()
    for _,fn in ipairs(langQueue) do pcall(fn,T()) end
end
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="CLAXHUB";ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.IgnoreGuiInset=true end)
ScreenGui.Parent=parentGui
local LOG_MAX=60
local logListeners={}
local function pushLog(kind,msg)
    local entry={kind=kind or "info",msg=tostring(msg),time=os.time()}
    table.insert(State.history,entry)
    while #State.history>LOG_MAX do table.remove(State.history,1) end
    for _,fn in ipairs(logListeners) do pcall(fn,entry) end
    pcall(saveState)
end
local SOUNDS={click="rbxassetid://6042053626",hover="rbxassetid://12221967",open="rbxassetid://6026984224",close="rbxassetid://6026984224",success="rbxassetid://6026984224",error="rbxassetid://5170537606",warning="rbxassetid://6042053626",boot="rbxassetid://9046705335",type="rbxassetid://6042053626",complete="rbxassetid://9046705335",theme="rbxassetid://12221967"}
local function playSound(name,volume,pitch)
    if not State.soundOn then return end
    local id=SOUNDS[name];if not id then return end
    pcall(function()
        local snd=Instance.new("Sound")
        snd.SoundId=id;snd.Volume=(volume or 0.5)*CONFIG.MasterVolume
        snd.PlaybackSpeed=pitch or 1;snd.Parent=SoundService;snd:Play()
        task.delay(4,function() if snd then snd:Destroy() end end)
    end)
end
local LOADER_ALIVE=true
local function isAlive() return LOADER_ALIVE end
local function killLoader() LOADER_ALIVE=false end
local TextService=game:GetService("TextService")
local LoaderGui=Instance.new("ScreenGui")
LoaderGui.Name="CLAXHUB_Loader";LoaderGui.ResetOnSpawn=false
LoaderGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() LoaderGui.IgnoreGuiInset=true end)
LoaderGui.DisplayOrder=999;LoaderGui.Parent=parentGui
local RED=Color3.fromRGB(255,35,50)
local RED_D=Color3.fromRGB(230,20,35)
local LBg=Instance.new("Frame",LoaderGui)
LBg.Size=UDim2.new(1,0,1,0);LBg.BackgroundColor3=Color3.fromRGB(0,0,0)
LBg.BackgroundTransparency=1;LBg.BorderSizePixel=0;LBg.ZIndex=0
LBg.ClipsDescendants=true
local LoaderBG=Instance.new("ImageLabel",LBg)
LoaderBG.Size=UDim2.new(1,0,1,0);LoaderBG.BackgroundTransparency=1
LoaderBG.Image=CONFIG.Background
LoaderBG.ScaleType=Enum.ScaleType.Stretch
LoaderBG.ImageTransparency=1;LoaderBG.ZIndex=0
local LoaderBGTint=Instance.new("Frame",LBg)
LoaderBGTint.Size=UDim2.new(1,0,1,0);LoaderBGTint.BackgroundColor3=Color3.fromRGB(0,0,0)
LoaderBGTint.BackgroundTransparency=1;LoaderBGTint.BorderSizePixel=0;LoaderBGTint.ZIndex=0
TweenService:Create(LoaderBG,TweenInfo.new(0.6),{ImageTransparency=0.05}):Play()
TweenService:Create(LoaderBGTint,TweenInfo.new(0.6),{BackgroundTransparency=0.8}):Play()
local Vig=Instance.new("Frame",LBg)
Vig.Size=UDim2.new(1,0,1,0);Vig.BackgroundColor3=Color3.fromRGB(0,0,0)
Vig.BackgroundTransparency=0.2;Vig.BorderSizePixel=0;Vig.ZIndex=1
local vg=Instance.new("UIGradient",Vig)
vg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(0.5,1),NumberSequenceKeypoint.new(1,0.9)})
vg.Rotation=0
local GridHolder=Instance.new("Frame",LBg)
GridHolder.Size=UDim2.new(1,0,1,0);GridHolder.BackgroundTransparency=1
GridHolder.ZIndex=1;GridHolder.ClipsDescendants=true
local gridLines={}
local GRID_V,GRID_H=80,90
for i=0,24 do
    local line=Instance.new("Frame",GridHolder)
    line.Size=UDim2.new(0,1,1,0);line.Position=UDim2.new(0,i*GRID_V,0,0)
    line.BackgroundColor3=RED;line.BackgroundTransparency=0.95
    line.BorderSizePixel=0;line.ZIndex=1
    table.insert(gridLines,{frame=line,idx=i,isV=true})
end
for i=0,16 do
    local line=Instance.new("Frame",GridHolder)
    line.Size=UDim2.new(1,0,0,1);line.Position=UDim2.new(0,0,0,i*GRID_H)
    line.BackgroundColor3=RED;line.BackgroundTransparency=0.95
    line.BorderSizePixel=0;line.ZIndex=1
    table.insert(gridLines,{frame=line,idx=i,isV=false})
end
task.spawn(function()
    local t=0
    while isAlive() and GridHolder.Parent do
        t=t+0.015
        local sz=LBg.AbsoluteSize
        local wV=math.max(sz.X,GRID_V*2)+GRID_V
        local wH=math.max(sz.Y,GRID_H*2)+GRID_H
        for _,g in ipairs(gridLines) do
            if g.isV then g.frame.Position=UDim2.new(0,(g.idx*GRID_V+t*90)%wV-GRID_V,0,0)
            else g.frame.Position=UDim2.new(0,0,0,(g.idx*GRID_H+t*50)%wH-GRID_H) end
        end
        task.wait(0.016)
    end
end)
local LGlow=Instance.new("ImageLabel",LBg)
LGlow.Size=UDim2.new(0,0,0,0);LGlow.Position=UDim2.new(0.5,0,0.5,0)
LGlow.AnchorPoint=Vector2.new(0.5,0.5);LGlow.BackgroundTransparency=1
LGlow.Image=CONFIG.Logo;LGlow.ScaleType=Enum.ScaleType.Fit
LGlow.ImageTransparency=1;LGlow.ZIndex=2
local Particles=Instance.new("Frame",LBg)
Particles.Size=UDim2.new(1,0,1,0);Particles.BackgroundTransparency=1
Particles.ZIndex=3
local particleList={}
for i=1,28 do
    local p=Instance.new("Frame",Particles)
    p.Size=UDim2.new(0,4,0,4)
    local ang=math.random()*math.pi*2
    local dist=380+math.random()*420
    p.Position=UDim2.new(0.5,math.cos(ang)*dist,0.5,math.sin(ang)*dist)
    p.AnchorPoint=Vector2.new(0.5,0.5);p.BackgroundColor3=RED
    p.BorderSizePixel=0;p.BackgroundTransparency=0.1;p.ZIndex=3
    Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
    table.insert(particleList,{frame=p,ang=ang,dist=dist})
end
local MatrixHolder=Instance.new("Frame",LBg)
MatrixHolder.Size=UDim2.new(1,0,0,70);MatrixHolder.Position=UDim2.new(0,0,1,-70)
MatrixHolder.BackgroundTransparency=1;MatrixHolder.ZIndex=4;MatrixHolder.ClipsDescendants=true
local chars="CLAXHUB01<>/\\[]{}#$@!"
local matrixPool={};local matrixActive=0;local MAX_MATRIX=14
local function acquireMatrixLabel()
    local lbl=table.remove(matrixPool)
    if lbl then return lbl end
    lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(0,20,0,70);lbl.BackgroundTransparency=1
    lbl.TextColor3=RED;lbl.Font=Enum.Font.Code
    lbl.TextSize=10;lbl.TextTransparency=0.4;lbl.ZIndex=4
    return lbl
end
task.spawn(function()
    while isAlive() and MatrixHolder.Parent do
        if matrixActive<MAX_MATRIX then
            matrixActive=matrixActive+1
            local cols=math.max(1,math.floor(LBg.AbsoluteSize.X/32))
            local col=math.random(1,cols)
            local lbl=acquireMatrixLabel()
            lbl.Parent=MatrixHolder
            lbl.Position=UDim2.new(0,(col-1)*32,0,-70)
            lbl.TextTransparency=0.4
            local parts={}
            for i=1,8 do
                local ci=math.random(1,#chars)
                parts[i]=chars:sub(ci,ci)
            end
            lbl.Text=table.concat(parts,"\n")
            local tw=TweenService:Create(lbl,TweenInfo.new(1.8,Enum.EasingStyle.Linear),{Position=UDim2.new(0,(col-1)*32,0,70),TextTransparency=1})
            tw:Play()
            tw.Completed:Connect(function()
                lbl.Parent=nil;matrixActive=matrixActive-1
                if #matrixPool<20 then table.insert(matrixPool,lbl) else lbl:Destroy() end
            end)
        end
        task.wait(0.12)
    end
end)
local TITLE_SIZE=28
local function measure(txt)
    local ok,v=pcall(function()
        return TextService:GetTextSize(txt,TITLE_SIZE,Enum.Font.GothamBlack,Vector2.new(2000,300))
    end)
    if ok and v then return v.X+6 end
    return #txt*TITLE_SIZE*0.8
end
local wC,wH=measure("CLAX"),measure("HUB")
local GAP=10
local total=wC+wH+GAP
local LHolder=Instance.new("Frame",LBg)
LHolder.Size=UDim2.new(1,0,0,240);LHolder.Position=UDim2.new(0.5,0,0.5,0)
LHolder.AnchorPoint=Vector2.new(0.5,0.5);LHolder.BackgroundTransparency=1;LHolder.ZIndex=5
local LClax=Instance.new("TextLabel",LHolder)
LClax.Size=UDim2.new(0,wC,0,40);LClax.AnchorPoint=Vector2.new(0,0.5)
LClax.Position=UDim2.new(0.5,-total/2-20,0.5,140);LClax.BackgroundTransparency=1
LClax.Text="CLAX";LClax.TextColor3=RED_D;LClax.Font=Enum.Font.GothamBlack
LClax.TextSize=TITLE_SIZE;LClax.TextTransparency=1
LClax.TextXAlignment=Enum.TextXAlignment.Left;LClax.ZIndex=6
local LHub=Instance.new("TextLabel",LHolder)
LHub.Size=UDim2.new(0,wH,0,40);LHub.AnchorPoint=Vector2.new(0,0.5)
LHub.Position=UDim2.new(0.5,-total/2+wC+GAP+20,0.5,140);LHub.BackgroundTransparency=1
LHub.Text="HUB";LHub.TextColor3=Color3.fromRGB(255,255,255);LHub.Font=Enum.Font.GothamBlack
LHub.TextSize=TITLE_SIZE;LHub.TextTransparency=1
LHub.TextXAlignment=Enum.TextXAlignment.Left;LHub.ZIndex=6
local LLine=Instance.new("Frame",LHolder)
LLine.Size=UDim2.new(0,0,0,1);LLine.Position=UDim2.new(0.5,0,0.5,158)
LLine.AnchorPoint=Vector2.new(0.5,0.5);LLine.BackgroundColor3=RED_D
LLine.BorderSizePixel=0;LLine.ZIndex=6
Instance.new("UICorner",LLine).CornerRadius=UDim.new(1,0)
local LComm=Instance.new("TextLabel",LHolder)
LComm.Size=UDim2.new(1,0,0,16);LComm.Position=UDim2.new(0.5,0,0.5,172)
LComm.AnchorPoint=Vector2.new(0.5,0);LComm.BackgroundTransparency=1
LComm.Text="C L A X   C O M M U N I T Y";LComm.TextColor3=Color3.fromRGB(200,200,210)
LComm.Font=Enum.Font.GothamBold;LComm.TextSize=9;LComm.TextTransparency=1;LComm.ZIndex=6
local LStatus=Instance.new("TextLabel",LBg)
LStatus.Size=UDim2.new(1,0,0,14);LStatus.Position=UDim2.new(0.5,0,1,-92)
LStatus.AnchorPoint=Vector2.new(0.5,0);LStatus.BackgroundTransparency=1
LStatus.Text="";LStatus.TextColor3=Color3.fromRGB(200,200,210)
LStatus.Font=Enum.Font.Code;LStatus.TextSize=10;LStatus.TextTransparency=1;LStatus.ZIndex=6
local LBarBg=Instance.new("Frame",LBg)
LBarBg.Size=UDim2.new(0,260,0,3);LBarBg.Position=UDim2.new(0.5,0,1,-74)
LBarBg.AnchorPoint=Vector2.new(0.5,0);LBarBg.BackgroundColor3=Color3.fromRGB(255,255,255)
LBarBg.BackgroundTransparency=1;LBarBg.BorderSizePixel=0;LBarBg.ZIndex=6
Instance.new("UICorner",LBarBg).CornerRadius=UDim.new(1,0)
local LBarFill=Instance.new("Frame",LBarBg)
LBarFill.Size=UDim2.new(0,0,1,0);LBarFill.BackgroundColor3=RED
LBarFill.BackgroundTransparency=1;LBarFill.BorderSizePixel=0;LBarFill.ZIndex=7
Instance.new("UICorner",LBarFill).CornerRadius=UDim.new(1,0)
local LDiscord=Instance.new("TextLabel",LBg)
LDiscord.Size=UDim2.new(1,0,0,16);LDiscord.Position=UDim2.new(0,0,1,-30)
LDiscord.BackgroundTransparency=1;LDiscord.Text="discord.gg/clax"
LDiscord.TextColor3=Color3.fromRGB(200,200,210);LDiscord.Font=Enum.Font.GothamBold
LDiscord.TextSize=11;LDiscord.TextTransparency=1;LDiscord.ZIndex=6
local LVer=Instance.new("TextLabel",LBg)
LVer.Size=UDim2.new(1,0,0,14);LVer.Position=UDim2.new(0,0,1,-14)
LVer.BackgroundTransparency=1;LVer.Text="v3.3 - CLAX HUB"
LVer.TextColor3=Color3.fromRGB(180,180,190);LVer.Font=Enum.Font.Code
LVer.TextSize=9;LVer.TextTransparency=1;LVer.ZIndex=6
local function setStatus(txt)
    if not isAlive() then return end
    LStatus.Text=txt
end
playSound("boot",0.5,1)
TweenService:Create(LGlow,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,380,0,380),ImageTransparency=0.82}):Play()
task.spawn(function()
    task.wait(0.2)
    for _,p in ipairs(particleList) do
        task.spawn(function()
            task.wait(math.random()*0.3)
            if not isAlive() then return end
            TweenService:Create(p.frame,TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,8,0,8),BackgroundTransparency=1}):Play()
        end)
    end
end)
local function LW(t) task.wait(t) end
LW(0.3)
local Shock=Instance.new("Frame",LBg)
Shock.Size=UDim2.new(0,0,0,0);Shock.Position=UDim2.new(0.5,0,0.5,0)
Shock.AnchorPoint=Vector2.new(0.5,0.5);Shock.BackgroundTransparency=1
Shock.BorderSizePixel=0;Shock.ZIndex=5
local shockRing=Instance.new("UIStroke",Shock)
shockRing.Color=RED;shockRing.Thickness=3;shockRing.Transparency=0.2
Instance.new("UICorner",Shock).CornerRadius=UDim.new(1,0)
local slideInfo=TweenInfo.new(0.5,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
TweenService:Create(LClax,slideInfo,{Position=UDim2.new(0.5,-total/2,0.5,140),TextTransparency=0}):Play()
TweenService:Create(LHub,slideInfo,{Position=UDim2.new(0.5,-total/2+wC+GAP,0.5,140),TextTransparency=0}):Play()
TweenService:Create(Shock,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,600,0,600)}):Play()
TweenService:Create(shockRing,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Thickness=1,Transparency=1}):Play()
task.delay(0.8,function() Shock:Destroy() end)
task.spawn(function()
    task.wait(0.6)
    for i=1,3 do
        if not isAlive() then return end
        local ring=Instance.new("Frame",LBg)
        ring.Size=UDim2.new(0,100,0,100);ring.Position=UDim2.new(0.5,0,0.5,0)
        ring.AnchorPoint=Vector2.new(0.5,0.5);ring.BackgroundTransparency=1
        ring.BorderSizePixel=0;ring.ZIndex=5
        local stroke=Instance.new("UIStroke",ring)
        stroke.Color=RED;stroke.Thickness=2;stroke.Transparency=0.1
        Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
        TweenService:Create(ring,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,800,0,800)}):Play()
        TweenService:Create(stroke,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Thickness=0.5,Transparency=1}):Play()
        task.delay(1.1,function() ring:Destroy() end)
        task.wait(0.15)
    end
end)
for i=1,4 do playSound("type",0.15,1.3+math.random()*0.3);task.wait(0.06) end
LW(0.1)
TweenService:Create(LLine,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,math.floor(total*0.9),0,1)}):Play()
playSound("hover",0.3,1.3)
LW(0.15)
TweenService:Create(LComm,TweenInfo.new(0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0}):Play()
playSound("type",0.2,1.5)
TweenService:Create(LBarBg,TweenInfo.new(0.4),{BackgroundTransparency=0.85}):Play()
TweenService:Create(LBarFill,TweenInfo.new(0.4),{BackgroundTransparency=0}):Play()
TweenService:Create(LStatus,TweenInfo.new(0.4),{TextTransparency=0.2}):Play()
TweenService:Create(LBarFill,TweenInfo.new(2.2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Size=UDim2.new(1,0,1,0)}):Play()
task.spawn(function()
    local steps={"> modules.init()","> theme.load()","> scripts.index()","> ui.build()","> ready"}
    for _,s in ipairs(steps) do
        if not isAlive() then return end
        setStatus(s)
        task.wait(0.42)
    end
end)
task.spawn(function()
    task.wait(0.5)
    local dir=1
    while isAlive() and LHolder.Parent do
        local tw=TweenService:Create(LHolder,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=UDim2.new(0.5,0,0.5,-3*dir)})
        tw:Play();tw.Completed:Wait();dir=-dir
    end
end)
local MAX_STARS=8;local starCount=0
task.spawn(function()
    task.wait(0.8)
    while isAlive() and LBg.Parent do
        if starCount<MAX_STARS then
            starCount=starCount+1
            local star=Instance.new("Frame",LBg)
            local size=math.random(2,5)
            star.Size=UDim2.new(0,size,0,size)
            star.Position=UDim2.new(0.5,math.random(-250,250),0.5,math.random(-150,150))
            star.AnchorPoint=Vector2.new(0.5,0.5)
            star.BackgroundColor3=RED;star.BorderSizePixel=0
            star.ZIndex=4
            Instance.new("UICorner",star).CornerRadius=UDim.new(1,0)
            local tw=TweenService:Create(star,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,math.random(-250,250),0.5,math.random(-150,150)),BackgroundTransparency=1,Size=UDim2.new(0,1,0,1)})
            tw:Play()
            tw.Completed:Connect(function() star:Destroy();starCount=starCount-1 end)
        end
        task.wait(0.08)
    end
end)
local MAX_FLAMES=6;local flameCount=0
task.spawn(function()
    task.wait(0.8)
    while isAlive() and LHolder.Parent do
        if flameCount<MAX_FLAMES then
            flameCount=flameCount+1
            local flame=Instance.new("Frame",LHolder)
            local size=math.random(4,10)
            local startX=math.random(-math.floor(total/2),math.floor(total/2))
            flame.Size=UDim2.new(0,size,0,size)
            flame.Position=UDim2.new(0.5,startX,0.5,148)
            flame.AnchorPoint=Vector2.new(0.5,0.5)
            flame.BackgroundColor3=math.random()>0.5 and RED or Color3.fromRGB(255,100,30)
            flame.BorderSizePixel=0;flame.BackgroundTransparency=0.3;flame.ZIndex=3
            Instance.new("UICorner",flame).CornerRadius=UDim.new(1,0)
            local tw=TweenService:Create(flame,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,startX+math.random(-20,20),0.5,120),Size=UDim2.new(0,1,0,1),BackgroundTransparency=1})
            tw:Play()
            tw.Completed:Connect(function() flame:Destroy();flameCount=flameCount-1 end)
        end
        task.wait(0.08)
    end
end)
local scanCount=0;local MAX_SCAN=1
task.spawn(function()
    task.wait(0.3)
    while isAlive() and LBg.Parent do
        if scanCount<MAX_SCAN then
            scanCount=scanCount+1
            local scan=Instance.new("Frame",LBg)
            scan.Size=UDim2.new(0,2,1,0);scan.Position=UDim2.new(0,-10,0,0)
            scan.BackgroundColor3=RED;scan.BackgroundTransparency=0.3
            scan.BorderSizePixel=0;scan.ZIndex=7
            local glow=Instance.new("Frame",scan)
            glow.Size=UDim2.new(0,20,1,0);glow.Position=UDim2.new(0,-20,0,0)
            glow.BackgroundColor3=RED;glow.BackgroundTransparency=0.85
            glow.BorderSizePixel=0
            local tw=TweenService:Create(scan,TweenInfo.new(1.5,Enum.EasingStyle.Linear),{Position=UDim2.new(1,10,0,0)})
            tw:Play()
            tw.Completed:Connect(function() scan:Destroy();scanCount=scanCount-1 end)
        end
        task.wait(0.4)
    end
end)
task.spawn(function()
    task.wait(1.0)
    for i=1,4 do
        if not isAlive() then return end
        local glitch=Instance.new("Frame",LHolder)
        glitch.Size=UDim2.new(0,math.random(20,50),0,math.random(2,4))
        local gx,gy=math.random(-80,80),140
        glitch.Position=UDim2.new(0.5,gx,0.5,gy)
        glitch.AnchorPoint=Vector2.new(0.5,0.5)
        glitch.BackgroundColor3=RED;glitch.BackgroundTransparency=0.2
        glitch.BorderSizePixel=0;glitch.ZIndex=7
        TweenService:Create(glitch,TweenInfo.new(0.1),{Position=UDim2.new(0.5,gx+math.random(-20,20),0.5,gy),BackgroundTransparency=1}):Play()
        task.delay(0.15,function() glitch:Destroy() end)
        task.wait(0.08)
    end
end)
LW(0.1)
TweenService:Create(LDiscord,TweenInfo.new(0.4),{TextTransparency=0}):Play()
TweenService:Create(LVer,TweenInfo.new(0.4),{TextTransparency=0}):Play()
playSound("success",0.5,1.1)
LW(2.0)
playSound("complete",0.6,1.15)
local fadeInfo=TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
TweenService:Create(LClax,fadeInfo,{TextTransparency=1,Position=UDim2.new(0.5,-total/2-20,0.5,140)}):Play()
TweenService:Create(LHub,fadeInfo,{TextTransparency=1,Position=UDim2.new(0.5,-total/2+wC+GAP+20,0.5,140)}):Play()
TweenService:Create(LLine,fadeInfo,{BackgroundTransparency=1}):Play()
TweenService:Create(LComm,fadeInfo,{TextTransparency=1}):Play()
TweenService:Create(LDiscord,fadeInfo,{TextTransparency=1}):Play()
TweenService:Create(LVer,fadeInfo,{TextTransparency=1}):Play()
TweenService:Create(LStatus,fadeInfo,{TextTransparency=1}):Play()
TweenService:Create(LBarBg,fadeInfo,{BackgroundTransparency=1}):Play()
TweenService:Create(LBarFill,fadeInfo,{BackgroundTransparency=1}):Play()
TweenService:Create(LoaderBG,fadeInfo,{ImageTransparency=1}):Play()
TweenService:Create(LoaderBGTint,fadeInfo,{BackgroundTransparency=1}):Play()
TweenService:Create(Vig,fadeInfo,{BackgroundTransparency=1}):Play()
TweenService:Create(LGlow,fadeInfo,{ImageTransparency=1}):Play()
LW(0.4)
killLoader()
LW(0.05)
LoaderGui:Destroy()
local NeonElements={}
local function registerNeon(fn) table.insert(NeonElements,fn) end
local themeConn=nil
local function applyTheme(key)
    if not THEMES[key] then return end
    if themeConn then themeConn:Disconnect();themeConn=nil end
    local oldTheme={}
    for k,v in pairs(C) do oldTheme[k]=v end
    local newTheme=THEMES[key]
    State.theme=key;saveState()
    local duration=0.45
    local elapsed=0
    themeConn=RunService.RenderStepped:Connect(function(dt)
        elapsed=elapsed+dt
        local p=math.min(elapsed/duration,1)
        local e=p<0.5 and (2*p*p) or (1-((-2*p+2)^2)/2)
        local blended={}
        for k,v in pairs(newTheme) do
            local ov=oldTheme[k]
            if typeof(v)=="Color3" and typeof(ov)=="Color3" then
                blended[k]=ov:Lerp(v,e)
            else
                blended[k]=v
            end
        end
        blended.name=newTheme.name
        C=blended
        for _,fn in ipairs(NeonElements) do pcall(fn,blended) end
        if p>=1 then
            themeConn:Disconnect();themeConn=nil
            C=newTheme
            for _,fn in ipairs(NeonElements) do pcall(fn,C) end
        end
    end)
end
local ToastHolder=Instance.new("Frame",ScreenGui)
ToastHolder.Size=UDim2.new(0,260,0,400);ToastHolder.Position=UDim2.new(1,-280,1,-420)
ToastHolder.BackgroundTransparency=1
local TL=Instance.new("UIListLayout",ToastHolder)
TL.Padding=UDim.new(0,6);TL.VerticalAlignment=Enum.VerticalAlignment.Bottom;TL.SortOrder=Enum.SortOrder.LayoutOrder
local toastN=0
local function toast(msg,col,dur)
    dur=dur or 3;col=col or C.Accent
    if not State.settings.notifications then return end
    table.insert(State.notifications,1,{msg=tostring(msg),time=os.time()})
    while #State.notifications>50 do table.remove(State.notifications) end
    toastN=toastN+1;if toastN>1000 then toastN=1 end
    local wrap=Instance.new("Frame",ToastHolder)
    wrap.Size=UDim2.new(1,0,0,40);wrap.BackgroundTransparency=1;wrap.LayoutOrder=toastN
    wrap.ClipsDescendants=false
    local f=Instance.new("Frame",wrap)
    f.Size=UDim2.new(1,0,1,0);f.BackgroundColor3=C.Card
    f.BackgroundTransparency=0.15;f.BorderSizePixel=0
    f.Position=UDim2.new(1,60,0,0)
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)
    local s=Instance.new("UIStroke",f);s.Color=C.Border;s.Thickness=1
    local dot=Instance.new("Frame",f)
    dot.Size=UDim2.new(0,7,0,7);dot.Position=UDim2.new(0,12,0.5,-3.5)
    dot.BackgroundColor3=col;dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-34,1,0);l.Position=UDim2.new(0,26,0,0)
    l.BackgroundTransparency=1;l.Text=msg;l.TextColor3=C.Text
    l.Font=Enum.Font.GothamMedium;l.TextSize=11;l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd
    if col==C.Success then playSound("success",0.35,1.1)
    elseif col==C.Danger then playSound("error",0.4,1)
    else playSound("click",0.25,1) end
    TweenService:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
    task.delay(dur,function()
        if f.Parent then
            TweenService:Create(f,TweenInfo.new(0.2),{Position=UDim2.new(1,60,0,0),BackgroundTransparency=1}):Play()
            TweenService:Create(l,TweenInfo.new(0.2),{TextTransparency=1}):Play()
            task.wait(0.25)
        end
        wrap:Destroy()
    end)
end
-- ============================================================
-- LOADING OVERLAY
-- ============================================================
local LoadingOverlay=Instance.new("Frame",ScreenGui)
LoadingOverlay.Name="LoadingOverlay"
LoadingOverlay.Size=UDim2.new(1,0,1,0)
LoadingOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
LoadingOverlay.BackgroundTransparency=0.55
LoadingOverlay.BorderSizePixel=0
LoadingOverlay.Visible=false
LoadingOverlay.ZIndex=500
pcall(function() LoadingOverlay.IgnoreGuiInset=true end)
local LOGrid=Instance.new("Frame",LoadingOverlay)
LOGrid.Size=UDim2.new(1,0,1,0)
LOGrid.BackgroundTransparency=1
LOGrid.ZIndex=501
LOGrid.ClipsDescendants=true
local loGridLines={}
for i=0,20 do
    local line=Instance.new("Frame",LOGrid)
    line.Size=UDim2.new(0,1,1,0)
    line.Position=UDim2.new(0,i*70-100,0,0)
    line.BackgroundColor3=C.Accent
    line.BackgroundTransparency=0.94
    line.BorderSizePixel=0
    line.ZIndex=501
    table.insert(loGridLines,{f=line,idx=i,isV=true})
end
for i=0,15 do
    local line=Instance.new("Frame",LOGrid)
    line.Size=UDim2.new(1,0,0,1)
    line.Position=UDim2.new(0,0,0,i*70-50)
    line.BackgroundColor3=C.Accent
    line.BackgroundTransparency=0.94
    line.BorderSizePixel=0
    line.ZIndex=501
    table.insert(loGridLines,{f=line,idx=i,isV=false})
end
task.spawn(function()
    local t=0
    while LoadingOverlay.Parent do
        if LoadingOverlay.Visible then
            t=t+0.02
            for _,g in ipairs(loGridLines) do
                if g.isV then g.f.Position=UDim2.new(0,(g.idx*70+t*60)%(math.max(LoadingOverlay.AbsoluteSize.X,1400)+140)-100,0,0)
                else g.f.Position=UDim2.new(0,0,0,(g.idx*70+t*40)%(math.max(LoadingOverlay.AbsoluteSize.Y,1000)+140)-50) end
            end
        end
        task.wait(0.016)
    end
end)
local LOBox=Instance.new("Frame",LoadingOverlay)
LOBox.Size=UDim2.new(0,0,0,0)
LOBox.Position=UDim2.new(0.5,0,0.5,0)
LOBox.AnchorPoint=Vector2.new(0.5,0.5)
LOBox.BackgroundColor3=C.Card
LOBox.BackgroundTransparency=0.1
LOBox.BorderSizePixel=0
LOBox.ZIndex=502
Instance.new("UICorner",LOBox).CornerRadius=UDim.new(0,16)
local loBoxStroke=Instance.new("UIStroke",LOBox)
loBoxStroke.Color=C.Accent;loBoxStroke.Thickness=1.5;loBoxStroke.Transparency=0.15
local LOLogo=Instance.new("ImageLabel",LOBox)
LOLogo.Size=UDim2.new(0,0,0,0)
LOLogo.Position=UDim2.new(0.5,0,0,10)
LOLogo.AnchorPoint=Vector2.new(0.5,0)
LOLogo.BackgroundTransparency=1
LOLogo.Image=CONFIG.Logo
LOLogo.ZIndex=503
local LOTitle=Instance.new("TextLabel",LOBox)
LOTitle.Size=UDim2.new(1,-24,0,20)
LOTitle.Position=UDim2.new(0.5,0,0,54)
LOTitle.AnchorPoint=Vector2.new(0.5,0)
LOTitle.BackgroundTransparency=1
LOTitle.Text=T().loadingTitle
LOTitle.TextColor3=C.Text
LOTitle.Font=Enum.Font.GothamBlack
LOTitle.TextSize=0
LOTitle.TextTransparency=0
LOTitle.ZIndex=503
local LOSub=Instance.new("TextLabel",LOBox)
LOSub.Size=UDim2.new(1,-24,0,16)
LOSub.Position=UDim2.new(0.5,0,0,80)
LOSub.AnchorPoint=Vector2.new(0.5,0)
LOSub.BackgroundTransparency=1
LOSub.Text=""
LOSub.TextColor3=C.TextDim
LOSub.Font=Enum.Font.Gotham
LOSub.TextSize=10
LOSub.TextTransparency=0
LOSub.ZIndex=503
local LOBarBg=Instance.new("Frame",LOBox)
LOBarBg.Size=UDim2.new(1,-40,0,4)
LOBarBg.Position=UDim2.new(0.5,0,0,108)
LOBarBg.AnchorPoint=Vector2.new(0.5,0)
LOBarBg.BackgroundColor3=C.Border
LOBarBg.BorderSizePixel=0
LOBarBg.ZIndex=503
Instance.new("UICorner",LOBarBg).CornerRadius=UDim.new(1,0)
local LOBarFill=Instance.new("Frame",LOBarBg)
LOBarFill.Size=UDim2.new(0,0,1,0)
LOBarFill.Position=UDim2.new(0,0,0,0)
LOBarFill.BackgroundColor3=C.Accent
LOBarFill.BorderSizePixel=0
LOBarFill.ZIndex=504
Instance.new("UICorner",LOBarFill).CornerRadius=UDim.new(1,0)
local LOSpinner=Instance.new("Frame",LOBox)
LOSpinner.Size=UDim2.new(0,20,0,20)
LOSpinner.Position=UDim2.new(1,-32,0,14)
LOSpinner.BackgroundTransparency=1
LOSpinner.ZIndex=503
local spinnerRing=Instance.new("Frame",LOSpinner)
spinnerRing.Size=UDim2.new(0,14,0,14)
spinnerRing.Position=UDim2.new(0.5,-7,0.5,-7)
spinnerRing.BackgroundColor3=C.Accent
spinnerRing.BorderSizePixel=0
spinnerRing.BackgroundTransparency=0
Instance.new("UICorner",spinnerRing).CornerRadius=UDim.new(1,0)
local spinnerDot=Instance.new("Frame",LOSpinner)
spinnerDot.Size=UDim2.new(0,4,0,4)
spinnerDot.Position=UDim2.new(0.5,-2,0,-2)
spinnerDot.AnchorPoint=Vector2.new(0.5,0.5)
spinnerDot.BackgroundColor3=C.CardHi
spinnerDot.BorderSizePixel=0
Instance.new("UICorner",spinnerDot).CornerRadius=UDim.new(1,0)
registerNeon(function(T2)
    LOBox.BackgroundColor3=T2.Card
    loBoxStroke.Color=T2.Accent
    LOTitle.TextColor3=T2.Text
    LOSub.TextColor3=T2.TextDim
    LOBarBg.BackgroundColor3=T2.Border
    LOBarFill.BackgroundColor3=T2.Accent
    spinnerRing.BackgroundColor3=T2.Accent
    spinnerDot.BackgroundColor3=T2.CardHi
    for _,g in ipairs(loGridLines) do g.f.BackgroundColor3=T2.Accent end
end)
local spinnerConn
local function startSpinner()
    if spinnerConn then spinnerConn:Disconnect() end
    spinnerConn=trackConn(RunService.RenderStepped:Connect(function()
        if not LoadingOverlay.Visible then return end
        local t=os.clock()
        LOSpinner.Rotation=(t*360)%360
        spinnerRing.BackgroundTransparency=0.15+math.abs(math.sin(t*3))*0.4
    end))
end
local function stopSpinner()
    if spinnerConn then spinnerConn:Disconnect();spinnerConn=nil end
end
local function showLoading(scriptName)
    LoadingOverlay.Visible=true
    LoadingOverlay.BackgroundTransparency=0.7
    LOLogo.Size=UDim2.new(0,0,0,0)
    LOTitle.TextSize=0
    LOSub.Text=scriptName or ""
    LOSub.TextSize=0
    LOBarFill.Size=UDim2.new(0,0,1,0)
    LOBarFill.BackgroundColor3=C.Accent
    LOBox.Size=UDim2.new(0,0,0,0)
    LOBox.BackgroundTransparency=1
    loBoxStroke.Transparency=1
    startSpinner()
    TweenService:Create(LoadingOverlay,TweenInfo.new(0.22),{BackgroundTransparency=0.55}):Play()
    TweenService:Create(LOBox,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,340,0,140),BackgroundTransparency=0.1}):Play()
    TweenService:Create(loBoxStroke,TweenInfo.new(0.35),{Transparency=0.15}):Play()
    TweenService:Create(LOLogo,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,40,0,40)}):Play()
    TweenService:Create(LOTitle,TweenInfo.new(0.3),{TextSize=14}):Play()
    TweenService:Create(LOSub,TweenInfo.new(0.3),{TextSize=10}):Play()
    TweenService:Create(LOBarFill,TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0.7,0,1,0)}):Play()
end
local function finishLoading(success)
    local targetColor=success and C.Success or C.Danger
    TweenService:Create(LOBarFill,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0),BackgroundColor3=targetColor}):Play()
    task.wait(0.3)
    local pulse=Instance.new("Frame",LOBox)
    pulse.Size=UDim2.new(1,0,1,0)
    pulse.BackgroundColor3=targetColor
    pulse.BackgroundTransparency=0.7
    pulse.BorderSizePixel=0
    pulse.ZIndex=505
    Instance.new("UICorner",pulse).CornerRadius=UDim.new(0,16)
    TweenService:Create(pulse,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
    task.delay(0.45,function() pulse:Destroy() end)
    task.wait(0.15)
    TweenService:Create(LoadingOverlay,TweenInfo.new(0.22),{BackgroundTransparency=1}):Play()
    TweenService:Create(LOBox,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1}):Play()
    TweenService:Create(loBoxStroke,TweenInfo.new(0.2),{Transparency=1}):Play()
    task.wait(0.25)
    stopSpinner()
    LoadingOverlay.Visible=false
    LoadingOverlay.BackgroundTransparency=0.55
end
local function forceCloseLoading()
    stopSpinner()
    LoadingOverlay.Visible=false
    LoadingOverlay.BackgroundTransparency=0.55
    LOBox.Size=UDim2.new(0,0,0,0)
end
local Main=Instance.new("Frame",ScreenGui)
Main.Size=UDim2.new(0,0,0,0)
Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.Position=UDim2.new(0.5,0,0.5,0)
Main.BackgroundColor3=C.Bg;Main.BackgroundTransparency=0.85
Main.BorderSizePixel=0;Main.Active=true;Main.ClipsDescendants=true;Main.Visible=false
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,18)
local MainBG=Instance.new("ImageLabel",Main)
MainBG.Name="BackgroundImage"
MainBG.Size=UDim2.new(1,0,1,0)
MainBG.BackgroundTransparency=1
MainBG.Image=CONFIG.Background
MainBG.ScaleType=Enum.ScaleType.Stretch
MainBG.ImageTransparency=0.05
MainBG.ZIndex=0
Instance.new("UICorner",MainBG).CornerRadius=UDim.new(0,18)
local MainBGOverlay=Instance.new("Frame",Main)
MainBGOverlay.Size=UDim2.new(1,0,1,0)
MainBGOverlay.BackgroundColor3=C.Bg
MainBGOverlay.BackgroundTransparency=0.85
MainBGOverlay.BorderSizePixel=0
MainBGOverlay.ZIndex=1
Instance.new("UICorner",MainBGOverlay).CornerRadius=UDim.new(0,18)
local dragMoved={}
local function drag(handle,target)
    local dragging,dragStart,startPos
    local activeInputConn=nil
    dragMoved[handle]=false
    trackConn(handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true;dragMoved[handle]=false;dragStart=input.Position;startPos=target.Position
            if activeInputConn then pcall(function() activeInputConn:Disconnect() end);activeInputConn=nil end
            activeInputConn=trackConn(input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    dragging=false
                    if activeInputConn then pcall(function() activeInputConn:Disconnect() end);activeInputConn=nil end
                end
            end))
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart
            if math.abs(delta.X)+math.abs(delta.Y)>5 then dragMoved[handle]=true end
            target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end))
end
local TopBar=Instance.new("Frame",Main)
TopBar.Size=UDim2.new(1,0,0,CONFIG.TopH);TopBar.BackgroundColor3=C.Bg
TopBar.BackgroundTransparency=0.2;TopBar.BorderSizePixel=0
TopBar.ZIndex=2
drag(TopBar,Main)
local TopLine=Instance.new("Frame",TopBar)
TopLine.Size=UDim2.new(1,0,0,1);TopLine.Position=UDim2.new(0,0,1,-1)
TopLine.BackgroundColor3=C.Border;TopLine.BorderSizePixel=0
registerNeon(function(T2) TopLine.BackgroundColor3=T2.Border end)
local LogoIcon=Instance.new("ImageLabel",TopBar)
LogoIcon.Size=UDim2.new(0,22,0,22);LogoIcon.Position=UDim2.new(0,14,0.5,-11)
LogoIcon.BackgroundTransparency=1;LogoIcon.Image=CONFIG.Logo
local Title=Instance.new("TextLabel",TopBar)
Title.Size=UDim2.new(0,140,1,0);Title.Position=UDim2.new(0,42,0,0)
Title.BackgroundTransparency=1;Title.Text=T().title;Title.TextColor3=C.Text
Title.Font=Enum.Font.GothamBlack;Title.TextSize=13;Title.TextXAlignment=Enum.TextXAlignment.Left
registerNeon(function(T2) Title.TextColor3=T2.Text end)
registerLang(function(t) Title.Text=t.title end)
local StatusDot=Instance.new("Frame",TopBar)
StatusDot.Size=UDim2.new(0,6,0,6);StatusDot.Position=UDim2.new(0,116,0.5,-3)
StatusDot.BackgroundColor3=C.Success;StatusDot.BorderSizePixel=0
Instance.new("UICorner",StatusDot).CornerRadius=UDim.new(1,0)
registerNeon(function(T2) StatusDot.BackgroundColor3=T2.Success end)
task.spawn(function()
    while ScreenGui.Parent and StatusDot.Parent do
        TweenService:Create(StatusDot,TweenInfo.new(0.9),{BackgroundTransparency=0.6}):Play()
        task.wait(0.9)
        TweenService:Create(StatusDot,TweenInfo.new(0.9),{BackgroundTransparency=0}):Play()
        task.wait(0.9)
    end
end)
local SearchBox=Instance.new("Frame",TopBar)
SearchBox.Size=UDim2.new(0,180,0,26);SearchBox.Position=UDim2.new(0.5,-90,0.5,-13)
SearchBox.BackgroundColor3=C.Card;SearchBox.BackgroundTransparency=0.2;SearchBox.BorderSizePixel=0
Instance.new("UICorner",SearchBox).CornerRadius=UDim.new(0,10)
local sbS=Instance.new("UIStroke",SearchBox);sbS.Color=C.Border;sbS.Thickness=1
registerNeon(function(T2) SearchBox.BackgroundColor3=T2.Card;sbS.Color=T2.Border end)
local SearchInput=Instance.new("TextBox",SearchBox)
SearchInput.Size=UDim2.new(1,-16,1,0);SearchInput.Position=UDim2.new(0,8,0,0)
SearchInput.BackgroundTransparency=1;SearchInput.Text=""
SearchInput.PlaceholderText=T().search;SearchInput.PlaceholderColor3=C.TextDim
SearchInput.TextColor3=C.Text;SearchInput.Font=Enum.Font.Gotham
SearchInput.TextSize=10;SearchInput.TextXAlignment=Enum.TextXAlignment.Left
SearchInput.ClearTextOnFocus=false
registerNeon(function(T2) SearchInput.TextColor3=T2.Text;SearchInput.PlaceholderColor3=T2.TextDim end)
registerLang(function(t) SearchInput.PlaceholderText=t.search end)
local LangBtn=Instance.new("TextButton",TopBar)
LangBtn.Size=UDim2.new(0,32,0,26);LangBtn.Position=UDim2.new(1,-68,0.5,-13)
LangBtn.BackgroundColor3=C.Card;LangBtn.BackgroundTransparency=0.2
LangBtn.Text=T().langBtn;LangBtn.TextColor3=C.Text
LangBtn.Font=Enum.Font.GothamBold;LangBtn.TextSize=10
LangBtn.BorderSizePixel=0;LangBtn.AutoButtonColor=false
Instance.new("UICorner",LangBtn).CornerRadius=UDim.new(0,10)
local lbS=Instance.new("UIStroke",LangBtn);lbS.Color=C.Border;lbS.Thickness=1
registerNeon(function(T2) LangBtn.BackgroundColor3=T2.Card;LangBtn.TextColor3=T2.Text;lbS.Color=T2.Border end)
registerLang(function(t) LangBtn.Text=t.langBtn end)
LangBtn.MouseEnter:Connect(function()
    TweenService:Create(LangBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.05,TextColor3=C.Accent}):Play()
end)
LangBtn.MouseLeave:Connect(function()
    TweenService:Create(LangBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.2,TextColor3=C.Text}):Play()
end)
LangBtn.MouseButton1Click:Connect(function()
    playSound("click",0.3,1)
    local newLang=(State.lang=="tr" and "en" or "tr")
    applyLang(newLang)
    toast(T().toastLangSwitch,C.Accent)
end)
local CloseBtn=Instance.new("TextButton",TopBar)
CloseBtn.Size=UDim2.new(0,26,0,26);CloseBtn.Position=UDim2.new(1,-36,0.5,-13)
CloseBtn.BackgroundColor3=C.Card;CloseBtn.BackgroundTransparency=0.2
CloseBtn.Text="X";CloseBtn.TextColor3=C.TextDim
CloseBtn.Font=Enum.Font.GothamBold;CloseBtn.TextSize=12
CloseBtn.BorderSizePixel=0;CloseBtn.AutoButtonColor=false
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,10)
local cbS=Instance.new("UIStroke",CloseBtn);cbS.Color=C.Border;cbS.Thickness=1
registerNeon(function(T2) CloseBtn.BackgroundColor3=T2.Card;CloseBtn.TextColor3=T2.TextDim;cbS.Color=T2.Border end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn,TweenInfo.new(0.12),{BackgroundColor3=C.Danger,TextColor3=C.Text,BackgroundTransparency=0.1}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn,TweenInfo.new(0.12),{BackgroundColor3=C.Card,TextColor3=C.TextDim,BackgroundTransparency=0.2}):Play()
end)
local Sidebar=Instance.new("Frame",Main)
Sidebar.Size=UDim2.new(0,CONFIG.SideW,1,-CONFIG.TopH-10)
Sidebar.Position=UDim2.new(0,10,0,CONFIG.TopH)
Sidebar.BackgroundColor3=C.Side;Sidebar.BackgroundTransparency=CONFIG.SideTrans
Sidebar.BorderSizePixel=0
Sidebar.ZIndex=2
Sidebar.ClipsDescendants=true
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,12)
local sideS=Instance.new("UIStroke",Sidebar);sideS.Color=C.Border;sideS.Thickness=1
registerNeon(function(T2) Sidebar.BackgroundColor3=T2.Side;sideS.Color=T2.Border end)
local SideScroll=Instance.new("ScrollingFrame",Sidebar)
SideScroll.Size=UDim2.new(1,-6,1,-6);SideScroll.Position=UDim2.new(0,3,0,3)
SideScroll.BackgroundTransparency=1;SideScroll.BorderSizePixel=0
SideScroll.ScrollBarThickness=2;SideScroll.ScrollBarImageColor3=C.Border
SideScroll.CanvasSize=UDim2.new(0,0,0,0);SideScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local SL=Instance.new("UIListLayout",SideScroll)
SL.Padding=UDim.new(0,2);SL.SortOrder=Enum.SortOrder.LayoutOrder
local Content=Instance.new("Frame",Main)
Content.Size=UDim2.new(1,-CONFIG.SideW-28,1,-CONFIG.TopH-10)
Content.Position=UDim2.new(0,CONFIG.SideW+18,0,CONFIG.TopH)
Content.BackgroundColor3=C.Bg;Content.BackgroundTransparency=CONFIG.ContentTrans
Content.BorderSizePixel=0;Content.ClipsDescendants=true
Content.ZIndex=2
Instance.new("UICorner",Content).CornerRadius=UDim.new(0,12)
local pages,tabOrder={},{}
local activeId="home"
local function origBT(ch)
    local o=ch:GetAttribute("OrigBT")
    if o==nil then o=ch.BackgroundTransparency;ch:SetAttribute("OrigBT",o) end
    return o
end
local function selectTab(id)
    if activeId==id then return end
    local prevId=activeId
    local prevPage=pages[prevId] and pages[prevId].page
    local newPage=pages[id] and pages[id].page
    if not newPage then return end
    if prevPage then
        task.spawn(function()
            local kids={}
            for _,ch in ipairs(prevPage:GetChildren()) do
                if ch:IsA("GuiObject") then
                    local o=origBT(ch)
                    table.insert(kids,{obj=ch,orig=o})
                    pcall(function() TweenService:Create(ch,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play() end)
                end
            end
            task.wait(0.13)
            if activeId~=prevId then prevPage.Visible=false end
            for _,k in ipairs(kids) do
                if k.obj.Parent then k.obj.BackgroundTransparency=k.orig end
            end
        end)
    end
    for _,k in ipairs(tabOrder) do
        local v=pages[k]
        v.btn.BackgroundColor3=C.Side;v.btn.BackgroundTransparency=1
        v.btn.TextColor3=C.TextDim;v.icon.TextColor3=C.TextDim;v.label.TextColor3=C.TextDim
        v.bar.BackgroundTransparency=1
    end
    local v=pages[id]
    v.btn.BackgroundColor3=C.Card;v.btn.BackgroundTransparency=0.15
    v.icon.TextColor3=C.Accent;v.label.TextColor3=C.Text
    v.bar.BackgroundTransparency=0
    newPage.Visible=true
    local down=(id=="home" or id=="favorites") and -18 or 18
    newPage.Position=UDim2.new(0,down,0,4)
    local targets={}
    for _,ch in ipairs(newPage:GetChildren()) do
        if ch:IsA("GuiObject") then
            local orig=origBT(ch)
            ch.BackgroundTransparency=1
            table.insert(targets,{obj=ch,orig=orig})
        end
    end
    TweenService:Create(newPage,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
        Position=UDim2.new(0,4,0,4)
    }):Play()
    for i,tg in ipairs(targets) do
        task.spawn(function()
            task.wait(i*0.015)
            pcall(function() TweenService:Create(tg.obj,TweenInfo.new(0.25),{BackgroundTransparency=tg.orig}):Play() end)
        end)
    end
    activeId=id;State.activeTab=id;saveState()
end
local function makeInfoBar(page)
    local bar=Instance.new("Frame",page)
    bar.Size=UDim2.new(1,0,0,26)
    bar.BackgroundTransparency=1
    bar.LayoutOrder=0
    local bl=Instance.new("UIListLayout",bar)
    bl.FillDirection=Enum.FillDirection.Horizontal
    bl.Padding=UDim.new(0,4)
    bl.SortOrder=Enum.SortOrder.LayoutOrder
    bl.VerticalAlignment=Enum.VerticalAlignment.Center
    local items={
        {key="infoSystem",target="home"},
        {key="infoCommunity",target="about",action="discord"},
        {key="infoCredits",target="about"},
        {key="infoGuide",target="about"}
    }
    for i,it in ipairs(items) do
        local b=Instance.new("TextButton",bar)
        b.Size=UDim2.new(0,0,1,0);b.AutomaticSize=Enum.AutomaticSize.X
        b.BackgroundColor3=C.Card;b.BackgroundTransparency=0.5
        b.Text=T()[it.key];b.TextColor3=C.TextDim
        b.Font=Enum.Font.GothamBold;b.TextSize=10
        b.BorderSizePixel=0;b.AutoButtonColor=false
        b.LayoutOrder=i
        local pad=Instance.new("UIPadding",b)
        pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10)
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        local bs=Instance.new("UIStroke",b);bs.Color=C.Border;bs.Thickness=1;bs.Transparency=0.6
        registerNeon(function(T2) b.BackgroundColor3=T2.Card;b.TextColor3=T2.TextDim;bs.Color=T2.Border end)
        registerLang(function(t) b.Text=t[it.key] end)
        b.MouseEnter:Connect(function()
            TweenService:Create(b,TweenInfo.new(0.12),{BackgroundTransparency=0.2,TextColor3=C.Text}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b,TweenInfo.new(0.12),{BackgroundTransparency=0.5,TextColor3=C.TextDim}):Play()
        end)
        b.MouseButton1Click:Connect(function()
            playSound("click",0.3,1)
            if it.action=="discord" then
                pcall(function() if setclipboard then setclipboard(CONFIG.Discord) end end)
                pcall(function() if openbrowser then openbrowser(CONFIG.Discord) end end)
                toast(T().toastCopied,C.Success)
                return
            end
            if pages[it.target] then selectTab(it.target) end
        end)
    end
end
local function makeSectionLabel(key)
    local lbl=Instance.new("TextLabel",SideScroll)
    lbl.Size=UDim2.new(1,-8,0,16);lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1;lbl.Text=T()[key]
    lbl.TextColor3=C.TextDim;lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=8;lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.LayoutOrder=(#tabOrder+1)*2-1
    registerNeon(function(T2) lbl.TextColor3=T2.TextDim end)
    registerLang(function(t) lbl.Text=t[key] end)
    return lbl
end
local function makeTab(id,labelKey,icon)
    local btn=Instance.new("TextButton",SideScroll)
    btn.Size=UDim2.new(1,0,0,30);btn.BackgroundColor3=C.Side
    btn.BackgroundTransparency=1;btn.Text="";btn.BorderSizePixel=0
    btn.AutoButtonColor=false;btn.LayoutOrder=(#tabOrder+1)*2
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local bar=Instance.new("Frame",btn)
    bar.Size=UDim2.new(0,2,0,16);bar.Position=UDim2.new(0,0,0.5,-8)
    bar.BackgroundColor3=C.Accent;bar.BorderSizePixel=0;bar.BackgroundTransparency=1
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    registerNeon(function(T2) bar.BackgroundColor3=T2.Accent end)
    local ic=Instance.new("TextLabel",btn)
    ic.Size=UDim2.new(0,18,1,0);ic.Position=UDim2.new(0,14,0,0)
    ic.BackgroundTransparency=1;ic.Text=icon;ic.TextColor3=C.TextDim
    ic.Font=Enum.Font.GothamBlack;ic.TextSize=12;ic.TextXAlignment=Enum.TextXAlignment.Left
    local lbl=Instance.new("TextLabel",btn)
    lbl.Size=UDim2.new(1,-38,1,0);lbl.Position=UDim2.new(0,36,0,0)
    lbl.BackgroundTransparency=1;lbl.Text=T()[labelKey];lbl.TextColor3=C.TextDim
    lbl.Font=Enum.Font.GothamMedium;lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.TextTruncate=Enum.TextTruncate.AtEnd
    registerLang(function(t) lbl.Text=t[labelKey] end)
    local page=Instance.new("ScrollingFrame",Content)
    page.Size=UDim2.new(1,-8,1,-8);page.Position=UDim2.new(0,4,0,4)
    page.BackgroundTransparency=1;page.BorderSizePixel=0
    page.ScrollBarThickness=3;page.ScrollBarImageColor3=C.Border
    page.CanvasSize=UDim2.new(0,0,0,0);page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=false
    local pl=Instance.new("UIListLayout",page)
    pl.Padding=UDim.new(0,7);pl.SortOrder=Enum.SortOrder.LayoutOrder
    pages[id]={page=page,btn=btn,icon=ic,label=lbl,bar=bar}
    table.insert(tabOrder,id)
    btn.MouseEnter:Connect(function()
        if activeId~=id then
            playSound("hover",0.15,1.3)
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.Card,BackgroundTransparency=0.6}):Play()
            TweenService:Create(lbl,TweenInfo.new(0.12),{TextColor3=C.Text}):Play()
            TweenService:Create(ic,TweenInfo.new(0.12),{TextColor3=C.Text}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeId~=id then
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=1}):Play()
            TweenService:Create(lbl,TweenInfo.new(0.12),{TextColor3=C.TextDim}):Play()
            TweenService:Create(ic,TweenInfo.new(0.12),{TextColor3=C.TextDim}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        playSound("click",0.3,1);selectTab(id)
    end)
    if id~="players" then makeInfoBar(page) end
    return page
end
local function makeCard(parent,h,order)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(1,0,0,h or 60);c.BackgroundColor3=C.Card
    c.BackgroundTransparency=CONFIG.CardTrans;c.BorderSizePixel=0
    c.LayoutOrder=order or 0
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,12)
    local s=Instance.new("UIStroke",c);s.Color=C.Border;s.Thickness=1
    registerNeon(function(T2) c.BackgroundColor3=T2.Card;s.Color=T2.Border end)
    return c
end
local homePage=makeTab("home","tabHome","H")
local discCard=makeCard(homePage,64,1)
discCard.Active=true
local discTitle=Instance.new("TextLabel",discCard)
discTitle.Size=UDim2.new(1,-50,0,18);discTitle.Position=UDim2.new(0,16,0,12)
discTitle.BackgroundTransparency=1
discTitle.Text=T().copyDiscord;discTitle.TextColor3=C.Text
discTitle.Font=Enum.Font.GothamBold;discTitle.TextSize=11
discTitle.TextXAlignment=Enum.TextXAlignment.Left
registerNeon(function(T2) discTitle.TextColor3=T2.Text end)
registerLang(function(t) discTitle.Text=t.copyDiscord end)
local discSub=Instance.new("TextLabel",discCard)
discSub.Size=UDim2.new(1,-50,0,14);discSub.Position=UDim2.new(0,16,0,32)
discSub.BackgroundTransparency=1
discSub.Text=T().copyDiscordSub;discSub.TextColor3=C.TextDim
discSub.Font=Enum.Font.Gotham;discSub.TextSize=10
discSub.TextXAlignment=Enum.TextXAlignment.Left
registerNeon(function(T2) discSub.TextColor3=T2.TextDim end)
registerLang(function(t) discSub.Text=t.copyDiscordSub end)
local discArrow=Instance.new("TextLabel",discCard)
discArrow.Size=UDim2.new(0,24,1,0);discArrow.Position=UDim2.new(1,-32,0,0)
discArrow.BackgroundTransparency=1
discArrow.Text=">";discArrow.TextColor3=C.TextDim
discArrow.Font=Enum.Font.GothamBold;discArrow.TextSize=22
discArrow.TextXAlignment=Enum.TextXAlignment.Center
registerNeon(function(T2) discArrow.TextColor3=T2.TextDim end)
local discBtn=Instance.new("TextButton",discCard)
discBtn.Size=UDim2.new(1,0,1,0);discBtn.BackgroundTransparency=1
discBtn.Text="";discBtn.BorderSizePixel=0;discBtn.AutoButtonColor=false
discBtn.MouseEnter:Connect(function()
    TweenService:Create(discCard,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play()
    TweenService:Create(discArrow,TweenInfo.new(0.15),{TextColor3=C.Accent,Position=UDim2.new(1,-26,0,0)}):Play()
end)
discBtn.MouseLeave:Connect(function()
    TweenService:Create(discCard,TweenInfo.new(0.15),{BackgroundTransparency=CONFIG.CardTrans}):Play()
    TweenService:Create(discArrow,TweenInfo.new(0.15),{TextColor3=C.TextDim,Position=UDim2.new(1,-32,0,0)}):Play()
end)
discBtn.MouseButton1Click:Connect(function()
    playSound("success",0.4,1.1)
    pcall(function() if setclipboard then setclipboard(CONFIG.Discord) end end)
    pcall(function() if openbrowser then openbrowser(CONFIG.Discord) end end)
    toast(T().toastCopied,C.Success)
end)
local welcome=makeCard(homePage,64,2)
welcome.ClipsDescendants=true
local wAvatar=Instance.new("ImageLabel",welcome)
wAvatar.Size=UDim2.new(0,38,0,38);wAvatar.Position=UDim2.new(0,14,0.5,-19)
wAvatar.BackgroundColor3=C.CardHi;wAvatar.BorderSizePixel=0;wAvatar.ZIndex=2
Instance.new("UICorner",wAvatar).CornerRadius=UDim.new(1,0)
local avS=Instance.new("UIStroke",wAvatar);avS.Color=C.Border;avS.Thickness=1
registerNeon(function(T2) wAvatar.BackgroundColor3=T2.CardHi;avS.Color=T2.Border end)
pcall(function()
    local lp=Players.LocalPlayer
    if lp then
        task.spawn(function()
            local ok,img=pcall(function()
                return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
            end)
            if ok and img and wAvatar.Parent then wAvatar.Image=img end
        end)
    end
end)
local wTitle=Instance.new("TextLabel",welcome)
wTitle.Size=UDim2.new(1,-70,0,20);wTitle.Position=UDim2.new(0,60,0,14)
wTitle.BackgroundTransparency=1
wTitle.Text=T().welcome.." "..(Players.LocalPlayer and Players.LocalPlayer.DisplayName or "user")
wTitle.TextColor3=C.Text;wTitle.Font=Enum.Font.GothamBold
wTitle.TextSize=13;wTitle.TextXAlignment=Enum.TextXAlignment.Left;wTitle.ZIndex=2
registerNeon(function(T2) wTitle.TextColor3=T2.Text end)
registerLang(function(t) wTitle.Text=t.welcome.." "..(Players.LocalPlayer and Players.LocalPlayer.DisplayName or "user") end)
local wSub=Instance.new("TextLabel",welcome)
wSub.Size=UDim2.new(1,-70,0,16);wSub.Position=UDim2.new(0,60,0,34)
wSub.BackgroundTransparency=1;wSub.Text=T().subtitle;wSub.TextColor3=C.TextDim
wSub.Font=Enum.Font.Gotham;wSub.TextSize=10
wSub.TextXAlignment=Enum.TextXAlignment.Left;wSub.ZIndex=2
registerNeon(function(T2) wSub.TextColor3=T2.TextDim end)
registerLang(function(t) wSub.Text=t.subtitle end)
local sysTitle=Instance.new("TextLabel",homePage)
sysTitle.Size=UDim2.new(1,0,0,14);sysTitle.BackgroundTransparency=1
sysTitle.Text=T().sysTitle;sysTitle.TextColor3=C.TextDim
sysTitle.Font=Enum.Font.GothamBold;sysTitle.TextSize=9
sysTitle.TextXAlignment=Enum.TextXAlignment.Left;sysTitle.LayoutOrder=3
registerNeon(function(T2) sysTitle.TextColor3=T2.TextDim end)
registerLang(function(t) sysTitle.Text=t.sysTitle end)
local sysCard=makeCard(homePage,160,4)
local sysGrid=Instance.new("UIGridLayout",sysCard)
sysGrid.CellSize=UDim2.new(0.5,-6,0,42);sysGrid.CellPadding=UDim2.new(0,6,0,6)
local sp=Instance.new("UIPadding",sysCard)
sp.PaddingLeft=UDim.new(0,8);sp.PaddingTop=UDim.new(0,8)
sp.PaddingRight=UDim.new(0,8);sp.PaddingBottom=UDim.new(0,8)
local infoRefs={}
local _fpsCount,_fpsValue=0,60
pcall(function() RunService:UnbindFromRenderStep("CLAX_FPS") end)
pcall(function()
    RunService:BindToRenderStep("CLAX_FPS",Enum.RenderPriority.First.Value,function() _fpsCount=_fpsCount+1 end)
end)
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        _fpsValue=_fpsCount;_fpsCount=0
    end
end)
local function infoCell(order,ico,labelKey,getVal)
    local cell=Instance.new("Frame",sysCard)
    cell.BackgroundColor3=C.CardHi;cell.BackgroundTransparency=0.15
    cell.BorderSizePixel=0;cell.LayoutOrder=order
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",cell);cs.Color=C.Border;cs.Thickness=1
    registerNeon(function(T2) cell.BackgroundColor3=T2.CardHi;cs.Color=T2.Border end)
    local i=Instance.new("TextLabel",cell)
    i.Size=UDim2.new(0,14,0,14);i.Position=UDim2.new(0,8,0,6)
    i.BackgroundTransparency=1;i.Text=ico;i.TextColor3=C.Accent
    i.TextSize=11;i.Font=Enum.Font.GothamBlack;i.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) i.TextColor3=T2.Accent end)
    local lt=Instance.new("TextLabel",cell)
    lt.Size=UDim2.new(1,-26,0,12);lt.Position=UDim2.new(0,24,0,6)
    lt.BackgroundTransparency=1;lt.Text=T()[labelKey];lt.TextColor3=C.TextDim
    lt.Font=Enum.Font.Gotham;lt.TextSize=9;lt.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) lt.TextColor3=T2.TextDim end)
    registerLang(function(t) lt.Text=t[labelKey] end)
    local vt=Instance.new("TextLabel",cell)
    vt.Size=UDim2.new(1,-16,0,18);vt.Position=UDim2.new(0,8,0,22)
    vt.BackgroundTransparency=1;vt.Text="...";vt.TextColor3=C.Text
    vt.Font=Enum.Font.GothamBold;vt.TextSize=12
    vt.TextXAlignment=Enum.TextXAlignment.Left;vt.TextTruncate=Enum.TextTruncate.AtEnd
    registerNeon(function(T2) vt.TextColor3=T2.Text end)
    table.insert(infoRefs,{lbl=vt,get=getVal})
end
infoCell(1,"<>","fps",function() return _fpsValue end)
infoCell(2,"~","ping",function()
    local p=0
    pcall(function()
        local item=Stats.Network.ServerStatsItem["Data Ping"]
        if item then p=math.floor(item:GetValue()) end
    end)
    if p<=0 then return "?" end
    return p.." ms"
end)
infoCell(3,"[]","executor",function()
    if identifyexecutor then
        local ok,n=pcall(identifyexecutor)
        if ok and n then return n end
    end
    return "Unknown"
end)
local _gameName=nil;local _gameTries=0
infoCell(4,"#","game",function()
    if _gameName then return _gameName end
    if _gameTries<5 then
        _gameTries=_gameTries+1
        local ok,info=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId) end)
        if ok and info and info.Name then _gameName=info.Name;return _gameName end
    end
    return "?"
end)
infoCell(5,"*","server",function() return tostring(game.JobId):sub(1,6):upper() end)
infoCell(6,"@","clock",function() return os.date("%H:%M").." - "..os.date("%d/%m") end)
task.spawn(function()
    local last=0
    while ScreenGui.Parent do
        local now=os.clock()
        if now-last>=1 then
            last=now
            for _,r in ipairs(infoRefs) do
                if not r.lbl.Parent then break end
                local ok,v=pcall(r.get)
                if ok and v~=nil then r.lbl.Text=tostring(v) end
            end
        end
        task.wait(0.25)
    end
end)
local statsTitle=Instance.new("TextLabel",homePage)
statsTitle.Size=UDim2.new(1,0,0,14);statsTitle.BackgroundTransparency=1
statsTitle.Text=T().statsTitle;statsTitle.TextColor3=C.TextDim
statsTitle.Font=Enum.Font.GothamBold;statsTitle.TextSize=9
statsTitle.TextXAlignment=Enum.TextXAlignment.Left;statsTitle.LayoutOrder=5
registerNeon(function(T2) statsTitle.TextColor3=T2.TextDim end)
registerLang(function(t) statsTitle.Text=t.statsTitle end)
local statsCard=makeCard(homePage,104,6)
local statsGrid=Instance.new("UIGridLayout",statsCard)
statsGrid.CellSize=UDim2.new(0.5,-6,0,40);statsGrid.CellPadding=UDim2.new(0,6,0,6)
local stp=Instance.new("UIPadding",statsCard)
stp.PaddingLeft=UDim.new(0,8);stp.PaddingTop=UDim.new(0,8)
stp.PaddingRight=UDim.new(0,8);stp.PaddingBottom=UDim.new(0,8)
local statRefs={}
local function statCell(order,labelKey,getVal)
    local cell=Instance.new("Frame",statsCard)
    cell.BackgroundColor3=C.CardHi;cell.BackgroundTransparency=0.15
    cell.BorderSizePixel=0;cell.LayoutOrder=order
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",cell);cs.Color=C.Border;cs.Thickness=1
    registerNeon(function(T2) cell.BackgroundColor3=T2.CardHi;cs.Color=T2.Border end)
    local lt=Instance.new("TextLabel",cell)
    lt.Size=UDim2.new(1,-16,0,12);lt.Position=UDim2.new(0,10,0,6)
    lt.BackgroundTransparency=1;lt.Text=T()[labelKey];lt.TextColor3=C.TextDim
    lt.Font=Enum.Font.Gotham;lt.TextSize=9;lt.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) lt.TextColor3=T2.TextDim end)
    registerLang(function(t) lt.Text=t[labelKey] end)
    local vt=Instance.new("TextLabel",cell)
    vt.Size=UDim2.new(1,-16,0,18);vt.Position=UDim2.new(0,10,0,20)
    vt.BackgroundTransparency=1;vt.Text="...";vt.TextColor3=C.Text
    vt.Font=Enum.Font.GothamBold;vt.TextSize=13
    vt.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) vt.TextColor3=T2.Text end)
    table.insert(statRefs,{lbl=vt,get=getVal})
end
statCell(1,"sessions",function() return State.stats.sessions end)
statCell(2,"loaded",function() return State.stats.scriptsLoaded end)
statCell(3,"favCount",function() local n=0;for _,v in pairs(State.favorites) do if v then n=n+1 end end;return n end)
statCell(4,"duration",function()
    local s=math.floor(os.clock()-State.sessionStart)
    local m=math.floor(s/60);local h=math.floor(m/60)
    if h>0 then return h.."h "..(m%60).."m" end
    if m>0 then return m.."m "..(s%60).."s" end
    return s.."s"
end)
task.spawn(function()
    while ScreenGui.Parent and statsCard.Parent do
        for _,r in ipairs(statRefs) do
            if not r.lbl.Parent then break end
            local ok,v=pcall(r.get)
            if ok and v~=nil then r.lbl.Text=tostring(v) end
        end
        task.wait(1)
    end
end)
local function scriptCard(parent,title,sub,urls,order,meta)
    local c=makeCard(parent,56,order)
    c:SetAttribute("IsScriptCard",true)
    c:SetAttribute("ScriptTitle",string.lower(title))
    c:SetAttribute("ScriptSub",string.lower(sub))
    local t=Instance.new("TextLabel",c)
    t.Size=UDim2.new(1,-165,0,16);t.Position=UDim2.new(0,18,0,11)
    t.BackgroundTransparency=1;t.Text=title;t.TextColor3=C.Text
    t.Font=Enum.Font.GothamBold;t.TextSize=12;t.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) t.TextColor3=T2.Text end)
    local s=Instance.new("TextLabel",c)
    s.Size=UDim2.new(1,-165,0,14);s.Position=UDim2.new(0,18,0,29)
    s.BackgroundTransparency=1;s.Text=sub;s.TextColor3=C.TextDim
    s.Font=Enum.Font.Gotham;s.TextSize=10;s.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) s.TextColor3=T2.TextDim end)
    local favBtn=Instance.new("TextButton",c)
    favBtn.Size=UDim2.new(0,20,0,20);favBtn.Position=UDim2.new(1,-134,0,18)
    favBtn.BackgroundColor3=State.favorites[title] and C.Accent or C.CardHi
    favBtn.BackgroundTransparency=State.favorites[title] and 0 or 0.3
    favBtn.Text="*";favBtn.TextColor3=State.favorites[title] and C.Text or C.TextDim
    favBtn.Font=Enum.Font.GothamBlack;favBtn.TextSize=10
    favBtn.BorderSizePixel=0;favBtn.AutoButtonColor=false
    Instance.new("UICorner",favBtn).CornerRadius=UDim.new(0,6)
    favBtn.MouseButton1Click:Connect(function()
        State.favorites[title]=not State.favorites[title]
        if State.favorites[title] then
            playSound("success",0.3,1.3)
            favBtn.BackgroundColor3=C.Accent;favBtn.BackgroundTransparency=0
            favBtn.TextColor3=C.Text
            toast(T().toastFavAdded,C.Accent)
        else
            playSound("click",0.3,0.9)
            favBtn.BackgroundColor3=C.CardHi;favBtn.BackgroundTransparency=0.3
            favBtn.TextColor3=C.TextDim
        end
        saveState()
        if GENV.CLAX_refreshFavs then GENV.CLAX_refreshFavs() end
    end)
    local autoBtn=Instance.new("TextButton",c)
    autoBtn.Size=UDim2.new(0,20,0,20);autoBtn.Position=UDim2.new(1,-106,0,18)
    autoBtn.BackgroundColor3=State.autoExec[title] and C.Accent or C.CardHi
    autoBtn.BackgroundTransparency=State.autoExec[title] and 0 or 0.3
    autoBtn.Text="A";autoBtn.TextColor3=State.autoExec[title] and C.Text or C.TextDim
    autoBtn.Font=Enum.Font.GothamBlack;autoBtn.TextSize=10
    autoBtn.BorderSizePixel=0;autoBtn.AutoButtonColor=false
    Instance.new("UICorner",autoBtn).CornerRadius=UDim.new(0,6)
    autoBtn.MouseButton1Click:Connect(function()
        State.autoExec[title]=not State.autoExec[title]
        if State.autoExec[title] then
            playSound("success",0.3,1.2)
            autoBtn.BackgroundColor3=C.Accent;autoBtn.BackgroundTransparency=0
            autoBtn.TextColor3=C.Text;toast(T().toastAuto.." "..title,C.Accent)
        else
            playSound("click",0.3,0.9)
            autoBtn.BackgroundColor3=C.CardHi;autoBtn.BackgroundTransparency=0.3
            autoBtn.TextColor3=C.TextDim
        end
        saveState()
    end)
    local btn=Instance.new("TextButton",c)
    btn.Size=UDim2.new(0,80,0,30);btn.Position=UDim2.new(1,-84,0.5,-15)
    btn.BackgroundColor3=C.CardHi;btn.BackgroundTransparency=0.2
    btn.Text=T().load;btn.TextColor3=C.Text
    btn.Font=Enum.Font.GothamBold;btn.TextSize=11
    btn.BorderSizePixel=0;btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    local bs=Instance.new("UIStroke",btn);bs.Color=C.Border;bs.Thickness=1
    registerNeon(function(T2) btn.BackgroundColor3=T2.CardHi;btn.TextColor3=T2.Text;bs.Color=T2.Border end)
    local busy=false
    registerLang(function(t)
        if not busy then btn.Text=t.load end
    end)
    c.MouseEnter:Connect(function()
        TweenService:Create(c,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play()
        TweenService:Create(bs,TweenInfo.new(0.15),{Color=C.TextDim}):Play()
    end)
    c.MouseLeave:Connect(function()
        TweenService:Create(c,TweenInfo.new(0.15),{BackgroundTransparency=CONFIG.CardTrans}):Play()
        TweenService:Create(bs,TweenInfo.new(0.15),{Color=C.Border}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy=true
        playSound("click",0.35,1);btn.Text=T().loading
        task.spawn(function()
            showLoading(title)
            local ok,err=pcall(function()
                local src=tryFetch(urls)
                if not src then error("source unavailable") end
                local fn,cerr=loadstring(src)
                if not fn then error("compile error: "..tostring(cerr)) end
                if setfenv and getfenv then pcall(setfenv,fn,getfenv()) end
                task.spawn(function()
                    local ok2,err2=pcall(fn)
                    if not ok2 then
                        warn("[CLAX runtime] "..title..": "..tostring(err2))
                        pushLog("error","runtime "..title.." - "..tostring(err2))
                    end
                end)
            end)
            if ok then
                playSound("success",0.5,1.1)
                btn.Text=T().okText;btn.TextColor3=C.Success
                toast(title.." "..T().toastLoaded,C.Success)
                pushLog("success","OK "..title.." "..T().toastLoaded)
                State.stats.scriptsLoaded=(State.stats.scriptsLoaded or 0)+1
                saveState()
            else
                playSound("error",0.5,1)
                btn.Text=T().errorText;btn.TextColor3=C.Danger
                toast(title.." "..T().toastError,C.Danger)
                warn(err)
                pushLog("error","X "..title.." - "..tostring(err))
            end
            pcall(finishLoading,ok)
            task.wait(0.3)
            btn.Text=T().load;btn.TextColor3=C.Text
            busy=false
        end)
    end)
    return c
end
local CATALOG={
{id="sae",icon="E",labelKey="tabSAE",scripts={
{"Zeroin Hub","zeroinhub.com",{"https://zeroinhub.com/api/script"}},
{"Sena Hub Beta","senahub.xyz",{"https://senahub.xyz/raw/loader","https://senahub.xyz/raw/loader.lua"}},
{"Sena Hub V6","senahub.xyz",{"https://senahub.xyz/senav6","https://senahub.xyz/senav6.lua"}},
{"Chilli Hub","tienkhanh1/spicy",{"https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"}},
{"Pulse Hub","PulseZax",{"https://raw.githubusercontent.com/PulseZax/Loader/refs/heads/main/.lua","https://raw.githubusercontent.com/PulseZax/Loader/main/.lua"}},
{"Miranda AFK","miirandahub",{"https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/afkk","https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/afkk.lua"}},
{"Lennon V4","lennonxscripts",{"https://raw.githubusercontent.com/lennonxscripts/lennonhubv4/refs/heads/main/stealanegg","https://raw.githubusercontent.com/lennonxscripts/lennonhubv4/refs/heads/main/stealanegg.lua"}}}},
{id="mm2",icon="M",labelKey="tabMM2",scripts={
{"Metan Hub","Youdfff",{"https://raw.githubusercontent.com/Youdfff/MetanHub/refs/heads/main/moonveil.lua"}},
{"Less Hub","ness-script",{"https://raw.githubusercontent.com/ness-script/mm2/main/hub","https://raw.githubusercontent.com/ness-script/mm2/main/hub.lua"}},
{"OverDrive","Keyless",{"https://raw.githubusercontent.com/MurderMystery2-Keyless-Script/Original/refs/heads/main/MainScript.lua"}},
{"Ruz Hub","rawscripts",{"https://rawscripts.net/raw/Universal-Script-RuzHub-239344"}},
{"Vertex","smokingscripts",{"https://raw.smokingscripts.org/vertex.lua"}}}},
{id="blox",icon="B",labelKey="tabBLOX",scripts={
{"Quantum Onyx","flazhy",{"https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/QuantumOnyx.lua"}},
{"Attack Hub","KOBENFF",{"https://raw.githubusercontent.com/KOBENFF/sdfd/refs/heads/main/Koatta.txt"}},
{"Yoxi Hub","Yomkav2",{"https://gist.githubusercontent.com/Yomkav2/8523e0d2877bfe00cf246c1bce15169f/raw/0c8e0851f3978b67300e24c9993f51bbe72ff822/bhntuijiung"}}}},
{id="base",icon="O",labelKey="tabBASE",scripts={
{"Ouroboros","joustingmatch",{"https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/loader.lua"}}}},
{id="ride",icon="R",labelKey="tabRIDE",scripts={
{"Mario Hub","xDTaraZz",{"https://raw.githubusercontent.com/xDTaraZz/Roblox-Scripts/refs/heads/main/loader.lua"}},
{"Thumbshub","luarmor",{"https://api.luarmor.net/files/v4/loaders/7a310d875453e7adb4fe6046e3ab0af9.lua"}}}},
{id="shader",icon="S",labelKey="tabShader",scripts={
{"Simple Shader","robloxscripts2026",{"https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/lua","https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/lua.lua","https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/init.lua"}}}},
{id="server",icon="H",labelKey="tabServer",scripts={
{"Rubu Hop","Bubu2k",{"https://raw.githubusercontent.com/Bubu2k/Rubutv/refs/heads/main/RubuHopSeverlow.lua"}}}},
{id="anim",icon="A",labelKey="tabAnim",scripts={
{"Pack Spy","Kixdev",{"https://raw.githubusercontent.com/Kixdev/animation-pack-spy/main/pack.lua"}}}},
{id="players",icon="P",labelKey="tabPlayers",scripts={}}}
local function detectGameTab()
    local gname=""
    pcall(function() gname=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    local lg=string.lower(gname)
    if lg:find("break and steal",1,true) or lg:find("break a steal",1,true) then return "base" end
    if lg:find("steal an egg",1,true) or lg:find("steal a egg",1,true) then return "sae" end
    if lg:find("murder mystery",1,true) or lg:find("mm2",1,true) then return "mm2" end
    if lg:find("blox fruit",1,true) then return "blox" end
    if lg:find("ride a pet",1,true) then return "ride" end
    return nil
end
local favPage=makeTab("favorites","tabFavorites","*")
local favList=Instance.new("Frame",favPage)
favList.Size=UDim2.new(1,0,0,0);favList.BackgroundTransparency=1
favList.LayoutOrder=1;favList.AutomaticSize=Enum.AutomaticSize.Y
local favLayout=Instance.new("UIListLayout",favList)
favLayout.Padding=UDim.new(0,7);favLayout.SortOrder=Enum.SortOrder.LayoutOrder
local favEmpty=Instance.new("TextLabel",favPage)
favEmpty.Size=UDim2.new(1,0,0,40);favEmpty.BackgroundTransparency=1
favEmpty.Text=T().favEmpty;favEmpty.TextColor3=C.TextDim
favEmpty.Font=Enum.Font.Gotham;favEmpty.TextSize=11
favEmpty.LayoutOrder=2;favEmpty.TextWrapped=true
registerNeon(function(T2) favEmpty.TextColor3=T2.TextDim end)
registerLang(function(t) favEmpty.Text=t.favEmpty end)
local function refreshFavorites()
    for _,ch in ipairs(favList:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    local count=0
    for _,cat in ipairs(CATALOG) do
        for _,s in ipairs(cat.scripts) do
            if State.favorites[s[1]] then
                count=count+1
                scriptCard(favList,s[1],s[2],s[3],count,cat.id)
            end
        end
    end
    favEmpty.Visible=(count==0)
end
GENV.CLAX_refreshFavs=refreshFavorites
refreshFavorites()
makeSectionLabel("sectionGames")
for _,cat in ipairs(CATALOG) do
    if cat.id~="players" then
        local p=makeTab(cat.id,cat.labelKey,cat.icon)
        for i,s in ipairs(cat.scripts) do
            scriptCard(p,s[1],s[2],s[3],i,cat.id)
        end
    end
end
makeSectionLabel("sectionTools")
local playersPage=makeTab("players","tabPlayers","P")
local playerConns={}
do
    local t=Instance.new("TextLabel",playersPage)
    t.Size=UDim2.new(1,0,0,14);t.BackgroundTransparency=1
    t.Text=T().playersTitle;t.TextColor3=C.TextDim
    t.Font=Enum.Font.GothamBold;t.TextSize=9
    t.TextXAlignment=Enum.TextXAlignment.Left;t.LayoutOrder=1
    registerNeon(function(T2) t.TextColor3=T2.TextDim end)
    registerLang(function(tt) t.Text=tt.playersTitle end)
    local playersList=Instance.new("Frame",playersPage)
    playersList.Size=UDim2.new(1,0,0,0);playersList.BackgroundTransparency=1
    playersList.LayoutOrder=2;playersList.AutomaticSize=Enum.AutomaticSize.Y
    local pll=Instance.new("UIListLayout",playersList)
    pll.Padding=UDim.new(0,6);pll.SortOrder=Enum.SortOrder.LayoutOrder
    local playerFrames={}
    local function buildPlayerCard(pl)
        local pc=Instance.new("Frame",playersList)
        pc.Size=UDim2.new(1,0,0,40);pc.BackgroundColor3=C.Card
        pc.BackgroundTransparency=0.15;pc.BorderSizePixel=0
        Instance.new("UICorner",pc).CornerRadius=UDim.new(0,12)
        local ps=Instance.new("UIStroke",pc);ps.Color=C.Border;ps.Thickness=1
        registerNeon(function(T2) pc.BackgroundColor3=T2.Card;ps.Color=T2.Border end)
        local nm=Instance.new("TextLabel",pc)
        nm.Size=UDim2.new(1,-100,1,0);nm.Position=UDim2.new(0,14,0,0)
        nm.BackgroundTransparency=1;nm.Text=pl.DisplayName
        nm.TextColor3=C.Text;nm.Font=Enum.Font.GothamBold
        nm.TextSize=12;nm.TextXAlignment=Enum.TextXAlignment.Left
        registerNeon(function(T2) nm.TextColor3=T2.Text end)
        local tpBtn=Instance.new("TextButton",pc)
        tpBtn.Size=UDim2.new(0,76,0,26);tpBtn.Position=UDim2.new(1,-88,0.5,-13)
        tpBtn.BackgroundColor3=C.CardHi;tpBtn.BackgroundTransparency=0.2
        tpBtn.Text=T().teleport;tpBtn.TextColor3=C.Text
        tpBtn.Font=Enum.Font.GothamBold;tpBtn.TextSize=10
        tpBtn.BorderSizePixel=0;tpBtn.AutoButtonColor=false
        Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,10)
        local tbs=Instance.new("UIStroke",tpBtn);tbs.Color=C.Border;tbs.Thickness=1
        registerNeon(function(T2) tpBtn.BackgroundColor3=T2.CardHi;tpBtn.TextColor3=T2.Text;tbs.Color=T2.Border end)
        registerLang(function(tt) tpBtn.Text=tt.teleport end)
        tpBtn.MouseButton1Click:Connect(function()
            playSound("click",0.35,1.1)
            pcall(function()
                local lp=Players.LocalPlayer
                local tgt=pl.Character
                if tgt and lp.Character then
                    local hrp=tgt:FindFirstChild("HumanoidRootPart")
                    local mh=lp.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and mh then mh.CFrame=hrp.CFrame+Vector3.new(0,3,0) end
                end
            end)
            toast(pl.DisplayName.." "..T().teleported,C.Success)
        end)
        return pc
    end
    local function refreshPlayers()
        local current={}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=Players.LocalPlayer then current[pl]=true end
        end
        for pl,frame in pairs(playerFrames) do
            if not current[pl] or not pl.Parent then frame:Destroy();playerFrames[pl]=nil end
        end
        local order=0
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=Players.LocalPlayer then
                order=order+1
                if not playerFrames[pl] then playerFrames[pl]=buildPlayerCard(pl) end
                playerFrames[pl].LayoutOrder=order
            end
        end
    end
    refreshPlayers()
    table.insert(playerConns,Players.PlayerAdded:Connect(function() task.wait(0.5);refreshPlayers() end))
    table.insert(playerConns,Players.PlayerRemoving:Connect(function() task.wait(0.5);refreshPlayers() end))
end
ScreenGui.Destroying:Connect(function()
    for _,c in ipairs(playerConns) do pcall(function() c:Disconnect() end) end
    if GENV.CLAX_CONNS then
        for _,c in ipairs(GENV.CLAX_CONNS) do pcall(function() c:Disconnect() end) end
        GENV.CLAX_CONNS={}
    end
    if themeConn then pcall(function() themeConn:Disconnect() end);themeConn=nil end
end)
local consolePage=makeTab("console","tabConsole","=")
local consoleHeader=makeCard(consolePage,40,1)
local chTitle=Instance.new("TextLabel",consoleHeader)
chTitle.Size=UDim2.new(1,-110,1,0);chTitle.Position=UDim2.new(0,18,0,0)
chTitle.BackgroundTransparency=1;chTitle.Text=T().consoleTitle
chTitle.TextColor3=C.TextDim;chTitle.Font=Enum.Font.GothamBold
chTitle.TextSize=9;chTitle.TextXAlignment=Enum.TextXAlignment.Left
registerNeon(function(T2) chTitle.TextColor3=T2.TextDim end)
registerLang(function(tt) chTitle.Text=tt.consoleTitle end)
local clearBtn=Instance.new("TextButton",consoleHeader)
clearBtn.Size=UDim2.new(0,80,0,26);clearBtn.Position=UDim2.new(1,-94,0.5,-13)
clearBtn.BackgroundColor3=C.CardHi;clearBtn.BackgroundTransparency=0.2
clearBtn.Text=T().clear;clearBtn.TextColor3=C.Text
clearBtn.Font=Enum.Font.GothamBold;clearBtn.TextSize=10
clearBtn.BorderSizePixel=0;clearBtn.AutoButtonColor=false
Instance.new("UICorner",clearBtn).CornerRadius=UDim.new(0,10)
local cbs=Instance.new("UIStroke",clearBtn);cbs.Color=C.Border;cbs.Thickness=1
registerNeon(function(T2) clearBtn.BackgroundColor3=T2.CardHi;clearBtn.TextColor3=T2.Text;cbs.Color=T2.Border end)
registerLang(function(tt) clearBtn.Text=tt.clear end)
local logsList=Instance.new("Frame",consolePage)
logsList.Size=UDim2.new(1,0,0,0);logsList.BackgroundTransparency=1
logsList.LayoutOrder=2;logsList.AutomaticSize=Enum.AutomaticSize.Y
local lll=Instance.new("UIListLayout",logsList)
lll.Padding=UDim.new(0,5);lll.SortOrder=Enum.SortOrder.LayoutOrder
local logOrder=0
local maxLogUI=LOG_MAX
local function levelColor(lvl)
    if lvl=="error" then return C.Danger end
    if lvl=="success" then return C.Success end
    return C.Accent
end
local function addLogUI(entry)
    logOrder=logOrder+1
    local c=Instance.new("Frame",logsList)
    c.Size=UDim2.new(1,0,0,34)
    c.BackgroundColor3=C.Card;c.BackgroundTransparency=0.35
    c.BorderSizePixel=0;c.LayoutOrder=logOrder
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",c)
    s.Color=levelColor(entry.kind);s.Thickness=1;s.Transparency=0.5
    local dot=Instance.new("Frame",c)
    dot.Size=UDim2.new(0,6,0,6);dot.Position=UDim2.new(0,10,0.5,-3)
    dot.BackgroundColor3=levelColor(entry.kind);dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local msg=Instance.new("TextLabel",c)
    msg.Size=UDim2.new(1,-100,1,0);msg.Position=UDim2.new(0,24,0,0)
    msg.BackgroundTransparency=1;msg.Text=entry.msg or ""
    msg.TextColor3=C.Text;msg.Font=Enum.Font.Code
    msg.TextSize=10;msg.TextXAlignment=Enum.TextXAlignment.Left
    msg.TextTruncate=Enum.TextTruncate.AtEnd
    local time=Instance.new("TextLabel",c)
    time.Size=UDim2.new(0,60,1,0);time.Position=UDim2.new(1,-68,0,0)
    time.BackgroundTransparency=1
    time.Text=os.date("%H:%M:%S",entry.time or os.time())
    time.TextColor3=C.TextDim;time.Font=Enum.Font.Code
    time.TextSize=9;time.TextXAlignment=Enum.TextXAlignment.Right
    local frames={}
    for _,ch in ipairs(logsList:GetChildren()) do
        if ch:IsA("Frame") then table.insert(frames,ch) end
    end
    if #frames>maxLogUI then frames[1]:Destroy() end
end
table.insert(logListeners,addLogUI)
for i=1,#State.history do addLogUI(State.history[i]) end
clearBtn.MouseButton1Click:Connect(function()
    playSound("click",0.3,1)
    State.history={}
    for _,ch in ipairs(logsList:GetChildren()) do
        if ch:IsA("Frame") then ch:Destroy() end
    end
    saveState();toast(T().toastHistoryCleared,C.Success)
end)
local aboutPage=makeTab("about","tabAbout","i")
local function aboutCardFn(order,titleKey,bodyKey,h)
    local card=makeCard(aboutPage,h or 150,order)
    local ttl=Instance.new("TextLabel",card)
    ttl.Size=UDim2.new(1,-32,0,20);ttl.Position=UDim2.new(0,16,0,14)
    ttl.BackgroundTransparency=1;ttl.Text=T()[titleKey]
    ttl.TextColor3=C.Text;ttl.Font=Enum.Font.GothamBold
    ttl.TextSize=11;ttl.TextXAlignment=Enum.TextXAlignment.Left
    registerNeon(function(T2) ttl.TextColor3=T2.Text end)
    registerLang(function(t) ttl.Text=t[titleKey] end)
    local bdy=Instance.new("TextLabel",card)
    bdy.Size=UDim2.new(1,-32,1,-50);bdy.Position=UDim2.new(0,16,0,38)
    bdy.BackgroundTransparency=1;bdy.Text=T()[bodyKey]
    bdy.TextColor3=C.TextDim;bdy.Font=Enum.Font.Gotham
    bdy.TextSize=11;bdy.TextXAlignment=Enum.TextXAlignment.Left
    bdy.TextYAlignment=Enum.TextYAlignment.Top;bdy.TextWrapped=true
    registerNeon(function(T2) bdy.TextColor3=T2.TextDim end)
    registerLang(function(t) bdy.Text=t[bodyKey] end)
end
aboutCardFn(1,"about","aboutBody",150)
aboutCardFn(2,"credits","creditsBody",80)
aboutCardFn(3,"community","communityBody",150)
aboutCardFn(4,"guide","guideBody",150)
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q=string.lower(SearchInput.Text)
    for _,cat in ipairs(CATALOG) do
        if pages[cat.id] and cat.id~="players" then
            local page=pages[cat.id].page
            for _,ch in ipairs(page:GetChildren()) do
                if ch:IsA("Frame") and ch:GetAttribute("IsScriptCard") then
                    if q=="" then
                        ch.Visible=true
                    else
                        local tt=ch:GetAttribute("ScriptTitle") or ""
                        local ss=ch:GetAttribute("ScriptSub") or ""
                        ch.Visible=(string.find(tt,q,1,true)~=nil) or (string.find(ss,q,1,true)~=nil)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    task.wait(1)
    local count=0
    for _,cat in ipairs(CATALOG) do
        for _,s in ipairs(cat.scripts) do
            if State.autoExec[s[1]] then
                count=count+1
                local ok,err=pcall(function()
                    local src=tryFetch(s[3])
                    if not src then error("source unavailable") end
                    local fn,cerr=loadstring(src)
                    if not fn then error("compile error: "..tostring(cerr)) end
                    if setfenv and getfenv then pcall(setfenv,fn,getfenv()) end
                    task.spawn(function()
                        local ok2,err2=pcall(fn)
                        if not ok2 then warn("[CLAX auto runtime] "..s[1]..": "..tostring(err2)) end
                    end)
                end)
                if ok then
                    pushLog("success","OK auto "..s[1].." "..T().toastLoaded)
                else
                    pushLog("error","X auto "..s[1].." - "..tostring(err))
                    warn("[CLAX auto] "..s[1]..": "..tostring(err))
                end
            end
        end
    end
    if count>0 then toast(count.." "..T().toastLoaded,C.Success) end
end)
task.spawn(function()
    task.wait(0.5)
    local detected=nil
    pcall(function() detected=detectGameTab() end)
    if detected and pages[detected] then
        selectTab(detected)
    else
        selectTab(State.activeTab or "home")
    end
end)
pages["home"].page.Visible=true
pages["home"].btn.BackgroundColor3=C.Card
pages["home"].btn.BackgroundTransparency=0.15
pages["home"].btn.TextColor3=C.Text
pages["home"].icon.TextColor3=C.Accent
pages["home"].label.TextColor3=C.Text
pages["home"].bar.BackgroundTransparency=0
activeId="home"
local Toggle=Instance.new("TextButton",ScreenGui)
Toggle.Size=UDim2.new(0,48,0,48);Toggle.Position=UDim2.new(0,18,0.5,-24)
Toggle.BackgroundColor3=C.Bg;Toggle.BackgroundTransparency=0.25
Toggle.Text="";Toggle.BorderSizePixel=0
Toggle.AutoButtonColor=false;Toggle.Visible=false
Instance.new("UICorner",Toggle).CornerRadius=UDim.new(0,24)
local toggleBg=Instance.new("ImageLabel",Toggle)
toggleBg.Size=UDim2.new(1,0,1,0)
toggleBg.BackgroundTransparency=1
toggleBg.Image=CONFIG.Background
toggleBg.ScaleType=Enum.ScaleType.Stretch
toggleBg.ImageTransparency=0.4
toggleBg.ZIndex=1
Instance.new("UICorner",toggleBg).CornerRadius=UDim.new(0,24)
local ti=Instance.new("ImageLabel",Toggle)
ti.Size=UDim2.new(1,-10,1,-10);ti.Position=UDim2.new(0,5,0,5)
ti.BackgroundTransparency=1;ti.Image=CONFIG.Logo;ti.ScaleType=Enum.ScaleType.Fit;ti.ZIndex=2
Instance.new("UICorner",ti).CornerRadius=UDim.new(0,20)
local tsSharp=Instance.new("UIStroke",Toggle)
tsSharp.Color=C.Accent;tsSharp.Thickness=1.5;tsSharp.Transparency=0.1
registerNeon(function(T2)
    Toggle.BackgroundColor3=T2.Bg
    tsSharp.Color=T2.Accent
    toggleBg.ImageColor3=Color3.fromRGB(255,255,255)
end)
drag(Toggle,Toggle)
local openBusy=false
-- Kapatma animasyonu kaldirildi - aninda gizlenir
local function setOpen(s)
    if openBusy then return end
    openBusy=true
    if s then
        playSound("open",0.4,1)
        Main.Visible=true;Toggle.Visible=false
        Main.Size=UDim2.new(0,0,0,0)
        TweenService:Create(Main,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,CONFIG.Width,0,CONFIG.Height)}):Play()
    else
        playSound("close",0.4,0.85)
        -- Animasyonsuz anlik kapatma
        Main.Visible=false
        Main.Size=UDim2.new(0,0,0,0)
        Toggle.Visible=true
    end
    task.delay(0.4,function() openBusy=false end)
end
CloseBtn.MouseButton1Click:Connect(function() setOpen(false) end)
Toggle.MouseButton1Click:Connect(function()
    if dragMoved[Toggle] then dragMoved[Toggle]=false;return end
    setOpen(true)
end)
trackConn(UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.Insert then
        if Main.Visible then setOpen(false) else setOpen(true) end
    end
end))
task.spawn(function()
    Main.Visible=true;Main.Size=UDim2.new(0,0,0,0)
    TweenService:Create(Main,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,CONFIG.Width,0,CONFIG.Height)}):Play()
    task.wait(0.4)
    toast(T().toastReady,C.Success)
end)
if GENV then
    GENV.CLAXHUB={Toggle=setOpen,UI=ScreenGui,Toast=toast,SetTheme=applyTheme,SetLang=applyLang,State=State,Discord=CONFIG.Discord,PlaySound=playSound,Sounds=SOUNDS,Log=pushLog,PushLog=pushLog,RefreshFavs=refreshFavorites}
end
print("[CLAX HUB] yuklendi - discord.gg/clax")
