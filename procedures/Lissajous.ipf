#pragma TextEncoding = "UTF-8"
#pragma rtGlobals = 3
#pragma rtFunctionErrors = 1
#pragma IgorVersion = 8.04
#pragma version = 1.0

// リサージュ曲線ビューア (Igor Pro 8.04 対応)
//
//   x(t) = sin(a * t + delta)
//   y(t) = sin(b * t)          t = 0 .. 2*pi
//
// 使い方:
//   メニュー Macros > Lissajous Panel でパネルを開き、
//   "Draw Lissajous" ボタンでグラフを描画する。
//   パネルの a, b, delta を変更するとグラフが即座に更新される。

static StrConstant kPanelName = "LissajousPanel"
static StrConstant kGraphName = "LissajousGraph"
static Constant kNumPoints = 2001

Menu "Macros"
	"Lissajous Panel", Lissajous_ShowPanel()
End

// グローバル変数を保持するデータフォルダを返す (無ければ作成)
static Function/DF GetPackageDF()

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Lissajous
	DFREF dfr = root:Packages:Lissajous

	NVAR/Z gA = dfr:gA
	if(!NVAR_Exists(gA))
		Variable/G dfr:gA = 3
	endif
	NVAR/Z gB = dfr:gB
	if(!NVAR_Exists(gB))
		Variable/G dfr:gB = 2
	endif
	NVAR/Z gDelta = dfr:gDelta
	if(!NVAR_Exists(gDelta))
		Variable/G dfr:gDelta = 90
	endif

	return dfr
End

// 現在のパラメータでリサージュ曲線のウェーブを計算する
static Function ComputeCurve()

	DFREF dfr = GetPackageDF()
	NVAR gA = dfr:gA
	NVAR gB = dfr:gB
	NVAR gDelta = dfr:gDelta

	Variable a = gA
	Variable b = gB
	Variable phase = gDelta * pi / 180

	Make/O/D/N=(kNumPoints) dfr:lissX, dfr:lissY
	WAVE wx = dfr:lissX
	WAVE wy = dfr:lissY
	SetScale/I x, 0, 2 * pi, "", wx, wy

	wx = sin(a * x + phase)
	wy = sin(b * x)

	return 0
End

// グラフを作成 (既にあれば前面へ)
static Function ShowGraph()

	DoWindow/F $kGraphName
	if(V_flag)
		return 0
	endif

	DFREF dfr = GetPackageDF()
	WAVE wx = dfr:lissX
	WAVE wy = dfr:lissY

	Display/N=$kGraphName/K=1 wy vs wx as "Lissajous Curve"

	ModifyGraph expand=2          // 倍率 2 倍
	ModifyGraph fSize=12          // フォントサイズ 12
	ModifyGraph mirror=1          // 上 (top) と右 (right) にミラー軸
	ModifyGraph tick=2            // 目盛りを内向き
	ModifyGraph height={Aspect, 1}
	ModifyGraph lsize=1.5, rgb=(0, 0, 52224)

	SetAxis left -1.1, 1.1
	SetAxis bottom -1.1, 1.1

	// 軸ラベルはフォントサイズ 16
	Label left "\\Z16y = sin(b t)"
	Label bottom "\\Z16x = sin(a t + delta)"

	return 0
End

// 再計算 (グラフは表示中のウェーブを参照しているので自動的に再描画される)
static Function UpdateCurve()

	ComputeCurve()
	DoUpdate
	return 0
End

// パネルを開く
Function Lissajous_ShowPanel()

	DoWindow/F $kPanelName
	if(V_flag)
		return 0
	endif

	GetPackageDF()
	ComputeCurve()

	NewPanel/N=$kPanelName/K=1/W=(100, 100, 380, 270) as "Lissajous"

	SetVariable setA, pos={20, 15}, size={240, 20}, bodyWidth=80
	SetVariable setA, title="a (x frequency)", limits={1, 20, 1}
	SetVariable setA, value=root:Packages:Lissajous:gA, proc=Lissajous_SetVarProc

	SetVariable setB, pos={20, 45}, size={240, 20}, bodyWidth=80
	SetVariable setB, title="b (y frequency)", limits={1, 20, 1}
	SetVariable setB, value=root:Packages:Lissajous:gB, proc=Lissajous_SetVarProc

	SetVariable setDelta, pos={20, 75}, size={240, 20}, bodyWidth=80
	SetVariable setDelta, title="delta (deg)", limits={0, 360, 15}
	SetVariable setDelta, value=root:Packages:Lissajous:gDelta, proc=Lissajous_SetVarProc

	Button btnDraw, pos={20, 115}, size={240, 35}, title="Draw Lissajous"
	Button btnDraw, proc=Lissajous_DrawButtonProc

	return 0
End

// "Draw Lissajous" ボタン
Function Lissajous_DrawButtonProc(STRUCT WMButtonAction &ba) : ButtonControl

	switch(ba.eventCode)
		case 2: // mouse up
			ComputeCurve()
			ShowGraph()
			break
		default:
			break
	endswitch

	return 0
End

// a / b / delta の変更に追従してグラフを更新
Function Lissajous_SetVarProc(STRUCT WMSetVariableAction &sva) : SetVariableControl

	switch(sva.eventCode)
		case 1: // fallthrough, mouse up (矢印クリック)
		case 2: // fallthrough, Enter キー
		case 3: // Live update
			UpdateCurve()
			break
		default:
			break
	endswitch

	return 0
End
