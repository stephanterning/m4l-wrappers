# Åtgärdsplan för M4L Wrappers v2

Bygg v2 som en separat generation av Oxford Inflator, Spectre och Decapitator. Använd friheten att välja ett nytt lagringsformat och nya interna parameter-ID:n där det förenklar lösningen. Låt v1 ligga kvar på sin befintliga sökväg för äldre set. Nya Spectre-instanser ska starta med **Quality = Good** och **De-Emphasis = på**, enligt produktbeslut.

**Arbetsordning.** Börja med två parallella arbeten. Lös sparning och Undo tillsammans eftersom båda berör skrivningar till Live. Utred samtidigt Decapitators exportlatens, eftersom resultatet kan avgöra vilken VST3-värd v2 behöver. Gör dessa försök med en liten prototyp innan alla tre enheter byggs om. Därefter följer Gain Match, Gain Link och slutprov.

## Implementationsbeslut, 25 november 2026

macOS prioriteras för Decapitator. Oxford och Spectre använder fortsatt Max för både uppslag och ljud. Decapitators macOS-enhet låter Max slå upp pluginen på namn och använder Steinbergs SDK för att bearbeta ljudet i det paket som Max hittade. Gain, mätare och enhetspaneler ligger kvar i Max. Windows för den nya värdkomponenten har ett separat verifieringssteg.

På macOS stöder v2 installation i standardmappen för VST3. Spectre i enbart Lives anpassade mapp gav torrsignal även efter Retry. En manuell filväljare är uppskjuten.

Enhetsbyggena finns i `dist/v2/`. Där finns också Spectres avsedda startvärden Good och De-Emphasis på. Resultaten för ljud, nivåmätning, sparning och Undo samt kvarvarande releaseprov finns i [verifieringen för v2](../tests/portable/verification.md#v2-development-on-macos).

**Det första anslaget i Decapitator.** Två direktinstanser i Live gav identiska 24-bitarsfiler i alla fem stilar när de fick samma insignal från start. När den ena fick digital tystnad och den andra en ton på −120 dBFS före samma anslag återskapade direktinstanserna den uppmätta skillnaden mot wrappern i Style A. Skillnaden var som störst 0,58 ms in i anslaget. Vid fortsatta ändringar ska både verklig tystnad och svagt ljud före anslaget ingå i jämförelsen.

**Latens vid export.** Wrappern ska rapportera sin faktiska fördröjning så att Live kan kompensera övriga spår och hantera medhörningen. Decapitator på macOS lämnar nu värdet när Live bygger ljudkedjan. I stabila Live 12.4.16 på macOS ändrades värdet från 62 till 110 samples vid export från 44,1 till 96 kHz och tillbaka till 62 efter exporten. Alla 95 impulser träffade torrkanalen på samma sample, inklusive impulsen på sample noll. Lösningen lägger ingen extra fördröjning i ljudvägen. Den tidigare prototypens fasta 205 samples behövs inte för detta fall.

Oxford och Spectre rapporterar ett ändrat latensvärde direkt när de får det från Max. De läser om värdet vid ljudomstart, när ett känt latenspåverkande reglage ändras och efter andra parameterändringar. Båda Oxford-lägena och alla tre provade Spectre-lägena låg på samma sample som direktpluginen vid sex exportfrekvenser. Vid 176,4 och 192 kHz låg Decapitator-wrappern i tid med torrspåret medan direktpluginen låg 95 samples efter i det provade setet.

**Sparning och Undo.** Tre Spectre-instanser återfick sina egna inställningar och sitt ljud efter sparning och återöppning med simulerat uppslagsfel och därefter Retry. Ett XY-drag gick att ångra och göra om på båda axlarna. Ett separat prov i Oxford visade att Gain Link skapar en extra Post-redigering vid ett manuellt Pre-drag och kan få Redo att försvinna. I v2 beräknas kompensationen separat i ljudvägen och Post Gain är fortsatt automatiserbar.

**Decapitators egen OutputTrim.** När AutoGain är på vid öppning låter v2 Soundtoys återställa utgångsnivån från pluginbanken och reagera på sparad Drive och Punish. Det löste fallet där en snabb sparning efter en Drive-ändring tidigare gav +3,50 dB. En separat begränsning gäller en uttrycklig manuell OutputTrim-ändring med AutoGain på. Vid sparning cirka 20 ms efter den sista ändringen återkom en 6,80 dB lägre nivå. Efter fullbordad lagring av pluginbanken återkom det exakta ljudet. Ett försök att läsa banken direkt vid rattändringen gav fortfarande fel nivå. Beslut för v2: detta specifika fall är en accepterad begränsning. De cirka 20 ms anger tidpunkten i provet. Wrappern schemalägger lagringen 150 ms efter sista trimändringen.

**Uppföljning i stabila Live 12.4.16.** Upprepade setbyten och tre samtidiga Spectre-Retry slutfördes. Manuell Undo/Redo för ett Drive-drag och automationsuppspelning med ett väntande Redo-steg är verifierade. Ett verkligt MIDI-CC styrde ett reglage per wrapper. Gain Match använde färska nivåer efter redigering i alla tre tillverkarnas pluginfönster. Oxford visar Off/On för sina tre brytare via Lives parameter-API. Decapitators inaktiva uppslagsinstans kostade cirka 21 MiB per ytterligare instans i separat Max efter första laddningen. Kvar inför utökat plattformsstöd är Windows x64. Det separata installationsprovet och fysisk visning av värdetexter på en kontrollenhet återstår. Oxfords CPU-kostnad är uppmätt och högre än för direkt VST3. [Mätvärden och provomfattning](../tests/portable/verification.md#follow-up-in-stable-live-12416-on-macos)

## 1. Tillförlitlig sparning och Undo

**Målet är att ett sparat set öppnas med det ljud som användaren valde och att en reglagegest kan ångras och göras om.**

- Prova instansbunden lagring genom det dokumenterade parameterläget i Max `vst~`. Verifiera att Live kan fånga hela plugintillståndet direkt vid sparning under pågående parameterändring. Kontrollera även att lagringen bevarar Redo. Detta är ett teknikval först när båda proven fungerar. [Cycling ’74 om vst~](https://docs.cycling74.com/reference/vst~/)
- Utse en ägare för varje uppgift. Pluginens fullständiga tillstånd ska bära dess interna inställningar, inklusive Soundtoys beräknade AutoGain-trim. Live ska bära automationskurvor och wrapperns egna reglage. Vid öppning återställs banken, reglagen synkroniseras och Live-automation får styra vid aktuell tidsposition. Vid pluginfel behålls instansens senast giltiga bank för Retry.
- Skilj mellan en ny ändring i pluginfönstret och pluginens svar på en ändring som Live just skickat. Ett sådant svar får uppdatera visningen utan att skapa ett nytt redigeringssteg. Tillämpa samma regel vid initiering, automation, Undo och Redo. Gruppera ett helt musdrag till en gest, även när Spectres XY-reglage ändrar två parametrar.
- Om Max-prototypen missar senaste ändringen eller bryter Redo, gå vidare till ett begränsat försök med en egen tillståndsbärare eller en VST3 SDK-värd för den produkt som behöver den. Utvärdera det tillsammans med latensprovet i steg 2. En kortare snapshot-timer lämnar kvar risken vid omedelbar sparning. Om ett ändrat tillstånd inte kan fångas ska användaren se en engelsk felstatus.

**Godkänt när** Drive 8,1 och Tone +2,5 återkommer efter sparning under täta ändringar och omstart av Live. Kör även omedelbar sparning efter redigering, två olika instanser, AutoGain av/på, manuellt OutputTrim och redigering från pluginfönstret. Jämför reglage, automationskurvor och ljud vid samma tidsposition. För varje wrapper ska en panelgest kunna ångras och göras om även efter att alla fördröjda svar hunnit fram. En tidigare separat redigering av spåret ska fortfarande gå att nå i båda riktningarna. Kontrollera MIDI-mappning och att ren uppspelning med automation lämnar historiken orörd. Prova även misslyckad lagring och en bank över v1.5:s gräns på 256 KiB.

## 2. Decapitator ska hamna rätt vid export

**Målet är noll samples relativ förskjutning mot samma VST3 direkt i Live med matchade inställningar.** V1.5 klarade 44,1 kHz men kom 48 samples tidigare vid export från 44,1 till 96 kHz. Realtid vid 96 kHz och export vid 96 kHz måste därför provas var för sig.

1. Behåll impulstestet och kontrollkedjan med 137 samples känd fördröjning. Utöka projektets diagnostiska VST3 så att den visar vilken samplingsfrekvens, blockstorlek och bearbetningsläge själva pluginen får direkt i Live respektive genom Max. Läs samtidigt vad enheten rapporterar till Live och mät var impulsen faktiskt hamnar. [Befintlig testplugin](../tests/max-host/precision/precision.cpp) · [Steinbergs ProcessSetup](https://steinbergmedia.github.io/vst3_doc/vstinterfaces/structSteinberg_1_1Vst_1_1ProcessSetup.html)
2. Kör kallstart i 96 kHz, uppspelning i 44,1 kHz, export till 96 kHz och återgång till uppspelning. Om felet gäller wrapperns rapportering, uppdatera den vid den faktiska DSP-omställningen i tid för första ljudblocket. Om `vst~` ger processorn fel inställningar, pröva en dokumenterad korrigering eller en avgränsad SDK-värd för Decapitator. Om Live kompenserar fel trots korrekta värden, isolera ett minimalt reproduktionsset för Ableton. En fast korrigering på 48 samples skulle också påverka lägen som redan ligger rätt.

**Godkänt när** första och följande impulser ligger på samma sample i direkt- och wrapperkanalen vid uppspelning, export och återgång. Kontrollera både Mix 0 % och bearbetad signal med matchade nivåer. Utöka till 44,1, 48, 88,2, 96, 176,4 och 192 kHz där de stöds. Kör även Oxford i båda Band Split-lägena och Spectre i Normal, Good och Best. Mät fysisk fördröjning och rapporterad latens för varje läge.

## 3. Gain Match ska bygga på det aktuella ljudet

Spärra knappen omedelbart när en faktisk ändring kan påverka ljudet, även från pluginfönstret, automation, presetbyte, Retry eller en DSP-omställning. Märk mätningarna så att sena svar från ett äldre fönster kan kastas. Låt nivåvisningen fortsätta arbeta. Aktivera Gain Match först när ramperna är klara och ett nytt tresekundersfönster med giltig ljudsignal har passerat. Återkoppling med samma värde ska inte starta om väntan.

**Godkänt när** ett klick direkt efter att pluginens utgång sänkts 6 dB lämnar Post Gain orört. När signalen redan är nivåmatchad ska den inte få ytterligare 6 dB dämpning. Upprepa för LUFS, RMS och peak, från både panelen och pluginfönstret. Kontrollera även att varje mått ger rätt korrigering när en verklig nivåskillnad finns kvar. [Gemensam mätarstyrning](../shared/meter-controls.js)

## 4. Separera Post Gain och kompensation för Pre Gain

I v2 sitter **Compensate output** under Pre Gain. När kryssrutan är på visar **Output compensation** under Post Gain det omvända värdet av Pre Gain i dB. När rutan är av visar den 0 dB. Post Gain är ett separat manuellt och automatiserbart reglage. Utgångssteget summerar Post Gain och kompensationen. Gain Match justerar användarens Post Gain med den uppmätta nivåskillnaden. Decapitators egen AutoGain fungerar oberoende av wrapperns kompensation.

**Godkänt när** Pre +6 dB och Post +2 dB ger −4 dB förstärkning efter pluginen med länken på och +2 dB med den av. Prova båda ordningarna för automation, manuell Undo/Redo, återöppning, Gain Match och ett kombinerat utgångsvärde på ±48 dB vid reglagens ytterlägen. Ett klick på rutan ska omedelbart lägga till eller ta bort hela det visade värdet med den vanliga korta gainrampen.

## 5. Startvärden, pluginfel och leverans

- **Spectre.** Ny instans ska ge Good och De-Emphasis på. Spara därefter Normal/av och Best/på i två instanser och kontrollera att varje instans återfår sitt eget val även efter Retry. Matcha uttryckligen läget vid jämförelse med direkt VST3.
- **Saknad plugin.** Ge en samlad engelsk varning med plugin- och spårnamn. Båda kanalerna ska passera torrt med oförändrad nivå även vid inställd Pre/Post Gain. Prova att spara och öppna setet medan pluginen är otillgänglig och återställ därefter installationen. Retry ska göra ett nytt uppslag och återställa rätt bank på varje spår. Testa även en verklig återinstallation och anpassad pluginsökväg. Beskriv Retry i användarinstruktionen.
- **Parameterkoppling och läsbarhet.** Verifiera pluginens klass och entydiga parameterkopplingar i stödda versioner. Visa en begriplig engelsk status vid saknad eller tvetydig parameter. Byt Oxfords `val1/val2` mot meningsfulla värdetexter och kontrollera att de visas rätt i Live och på kontrollenheter.
- **Äldre set.** Ge v2 en separat installationsplats och tydlig identitet i Live. Kontrollera med båda generationerna installerade att ett äldre set hittar v1 och ett nytt set hittar v2. Den första v2-leveransen kan avstå från automatisk migrering av banker och automation. Beskriv hur användaren behåller v1 för gamla projekt.
- **Slutprov.** Lägg de reproducerbara felfallen i projektets testsamling. Kör ljud-, latens-, CPU- och sparproven på stabil Live för macOS och på Windows x64 inför stöd för den plattformen. Mät CPU mot direkt VST3 och v1.5 vid samma signal, läge, blockstorlek och samplingsfrekvens. Utred märkbara regressioner i synnerhet för Oxford. Bygg versionsfria `.amxd` i en separat v2-katalog under utveckling. Skapa versionsmärkta zippar först vid releaseförberedelsen.

Utgå från de dokumenterade referensmätningarna och behåll det gamla jämförelseutfallet bredvid resultatet för v2. [Tidigare ljud- och CPU-prov](../tests/portable/verification.md)
