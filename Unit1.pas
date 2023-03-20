unit Unit1;

interface

uses
  System, System.Drawing, System.Threading, System.IO, System.Security.Cryptography, System.Windows.Forms;

type
  Form1 = class(Form)
    procedure Form1_Load(sender: Object; e: EventArgs);
    procedure Form1_SizeChanged(sender: Object; e: EventArgs);
    procedure button1_Click(sender: Object; e: EventArgs);
    procedure button2_Click(sender: Object; e: EventArgs);
    procedure button3_Click(sender: Object; e: EventArgs);
    procedure button4_Click(sender: Object; e: EventArgs);
    procedure button5_Click(sender: Object; e: EventArgs);
    procedure checkBox1_CheckedChanged(sender: Object; e: EventArgs);
    procedure dataGridView1_KeyUp(sender: Object; e: KeyEventArgs);
    procedure dataGridView1_KeyDown(sender: Object; e: KeyEventArgs);
    procedure dataGridView1_CellMouseUp(sender: Object; e: DataGridViewCellMouseEventArgs);
    procedure dataGridView1_CellMouseDoubleClick(sender: Object; e: DataGridViewCellMouseEventArgs);
    procedure dataGridView2_CellMouseDoubleClick(sender: Object; e: DataGridViewCellMouseEventArgs);
    procedure GetHashesThread;
    procedure UpdateInterface(mString: String);
    function GetFileFolderName(mStr: string): string;
    function SortingFolders(mFirstCall: boolean): integer;
    function GetMixHashes(mArray: array of string): string;
    function GetHashFile(mPath: string): string;
    function GetHashFolder(mPath: string): string;
  {$region FormDesigner}
  internal
    {$resource Unit1.Form1.resources}
    button1: Button;
    textBox1: TextBox;
    button2: Button;
    button3: Button;
    button4: Button;
    button5: Button;
    dataGridView1: DataGridView;
    dataGridView2: DataGridView;
    progressBar1: ProgressBar;
    statusStrip1: StatusStrip;
    folderBrowserDialog1: FolderBrowserDialog;
    Column1: DataGridViewTextBoxColumn;
    Column2: DataGridViewTextBoxColumn;
    Column3: DataGridViewTextBoxColumn;
    Column4: DataGridViewTextBoxColumn;
    checkBox1: CheckBox;
    toolStripStatusLabel1: ToolStripStatusLabel;
    {$include Unit1.Form1.inc}
  {$endregion FormDesigner}
  public
    constructor;
    begin
      InitializeComponent;
    end;
  end;

implementation

type
  mObjectData = record // запись Файл/Папка (с путем и хэшем)
    fullpath: string; // полный путь к файлу
    namefile: string; // только имя и расширение файла
    hashfile: string; // хэш файла
    hashpath: string; // хэш файла и полного пути к нему
  end;
  
  mFolderData = record // запись Папка (с дублями, пути в массиве)
    index: integer;         // индекс
    fullpath: string;       // полный путь к папке
    namefolder: string;     // только имя папки (с ключом .ToLower)
    hash: string;           // хэш папки
    ddir: array of string;  // массив путей к папкам-дублям
    ddix: array of integer; // массив индексов папок-дублей
  end;

var
  mThr: Thread;                                   // поток сканирования
  mMainPatch: string = '';                        // начальная папка
  mFoldersList: sequence of string;               // список всех папок
  mSelectDD4Delete,                               // индекс выбранной пользователем папки для удаления ее дублей
  mCountAllFiles: integer;                        // количество всех файлов (для progressbar)
  mFilesList: array of mObjectData;               // массив данных всех файлов (путь + хэш)
  mMainList: array of mFolderData;                // массив данных всех папок (путь + хэш + флаг показа + дубли)
  mThreadOn: boolean = false;                     // состояние потока (сканирование папок)
  mThreadSuspend: boolean = false;                // приостановка потока (сканирование папок)
  mCheckNames: boolean = false;                   // флаг учета имен файлов/папок
  // mException: boolean = false;                 // флаг исключения длинных имен (.NET Framework 4.6.2 или выше)
  mNameStatusLabel: string = 'Ready';             // текст на toolStripStatusLabel1
  mProgressBarPosition: byte;                     // заполнение ProgressBar1 (от 0 до 100)
  mNameStartStopButton: string = 'Start Compare'; // текст на Button2

// внешняя функция отображения окна сообщения
function MessageBox(h: integer; m, c: string; t: integer): integer; external 'User32.dll' name 'MessageBox';

// выделение имени файла/папки из полного пути
function Form1.GetFileFolderName(mStr: string): string;
begin
  // проверка длины полного пути файла/папки
  Result := '';
  if mStr.Length <= 3 then
  begin
    MessageBox(Handle.ToInt32, 'Error file/folder name!', 'Warning', 0);
    if mThreadOn then button2_Click(Self, nil); // остановка потока (сканирование файлов)
    Exit;
  end;
  // для mStr длиной 4 символа и более (имя папки/файла начинается с 4 символа, первые 3 - 'c:\'
  // минимальная длина пути папки и файла (без расширения) - 1 символ
  // в конце пути папки может стоять '\'
  // удаление последнего символа строки '\', если он есть
  if mStr[mStr.Length - 1] = '\' then mStr := LeftStr(mStr, (mStr.Length - 1));
  // или - if mStr[mStr.Length - 1] = '\' then mStr := Copy(mStr, 1, (mStr.Length - 1));
  Result := RightStr(mStr, (mStr.Length - LastPos('\', mStr))).ToLower;
end;

// сортировка папок-дублей
function Form1.SortingFolders(mFirstCall: boolean): integer;
begin
  var m: integer := mMainList.Length - 1;
  // подсчет количества папок-дублей, при первом вызове функции - назначение индексов только папкам, имеющим дубли
  var c: integer := 0; // первичный счетчик папок с дублями (передается в Result)
  for var mCurr: integer := 0 to m do
  begin
    var b: boolean := false; // флаг наличия повторных дублей после каждого i-цикла (при повторных вызовах функции)
    for var i: integer := 0 to m do
    begin
      // определение правил поиска совпадений папок - учитывать совпадение имен или нет
      var mNameMatchNec: boolean := true;
      if mCheckNames and (mMainList[mCurr].namefolder <> mMainList[i].namefolder) then mNameMatchNec := false;
      // поиск совпадений текущего элемента в массиве mMainList с остальными по ненулевому hash (пути должны отличаться)
      // - при каждом вызове: для подсчета папок-дублей
      // - при первом вызове: для присвоения индексов всем папкам, имеющим дубли
      if (mCurr <> i) and
          mNameMatchNec and
         (mMainList[mCurr].hash <> '') and
         (mMainList[mCurr].hash = mMainList[i].hash) then
      begin
        if mFirstCall then
        begin
          if (mMainList[mCurr].index = 0) then
          begin
            inc(c);
            mMainList[mCurr].index := c;
          end;
        end
        else
          b := true;
      end;
    end;
    if (not mFirstCall) and b then inc(c);
  end;
  // при первом вызове функции - заполнение подсписков папок-дублей (пути, индексы)
  if mFirstCall then
    for var mCurr: integer := 0 to m do
    begin
      SetLength(mMainList[mCurr].ddir, 0);
      SetLength(mMainList[mCurr].ddix, 0);
      var tmp: integer := 0;
      for var j: integer := 0 to m do
      begin
        // определение правил поиска совпадений папок - учитывать совпадение имен или нет
        var mNameMatchNec: boolean := true;
        if mCheckNames and (mMainList[mCurr].namefolder <> mMainList[j].namefolder) then mNameMatchNec := false;
        // поиск совпадений текущего элемента в массиве mMainList с остальными по ненулевому hash (пути должны отличаться)
        // - заполнение подсписков папок-дублей
        if (mCurr <> j) and
            mNameMatchNec and
           (mMainList[mCurr].hash <> '') and
           (mMainList[mCurr].hash = mMainList[j].hash) then
        begin
          inc(tmp);
          SetLength(mMainList[mCurr].ddir, tmp);
          mMainList[mCurr].ddir[tmp - 1] := mMainList[j].fullpath; // пути к папкам-дублям
          SetLength(mMainList[mCurr].ddix, tmp);
          mMainList[mCurr].ddix[tmp - 1] := mMainList[j].index; // индексы папок-дублей в массиве mMainList
        end;
      end;
    end;
  Result := c;
end;

// хэширование строки (собранной из массива строк) по алгоритму md5
function Form1.GetMixHashes(mArray: array of string): string;
begin
  // если в массиве один элемент, передать его хэш как результирующий
  if mArray.Length = 1 then
  begin
    Result := mArray[0];
    Exit;
  end;
  // рассчитать хэш строки, собранной из массива mArray
  var mStr: string := '';
  for var j: integer := 0 to (mArray.Length - 1) do mStr := mStr + mArray[j];
  var st: string := '';
  try
    var md5 := new MD5CryptoServiceProvider();
    var mVal := md5.ComputeHash(Encoding.Default.GetBytes(mStr));
    var sb := new StringBuilder();
    var i: integer := 0;
    while i < mVal.Length do
    begin
      sb.Append(mVal[i].ToString('x2'));
      inc(i);
    end;
    st := sb.ToString;
  except
  //  begin
  //  end;
  end;
  Result := st;
end;

// хэширование файла по алгоритму md5
function Form1.GetHashFile(mPath: string): string;
begin
  // проверка на повтор (поиск файла в массиве ранее уже обсчитанных файлов)
  if mFilesList.Length > 0 then // в массиве есть элементы
    foreach var fn in mFilesList do
      if fn.fullpath = mPath then
      begin
        if mCheckNames then Result := fn.hashpath else Result := fn.hashfile;
        Exit;
      end;
  // если не найдено совпадение, то рассчитать хэш по алгоритму md5
  var st: string := '';
  try
    var fs := new System.IO.FileStream(mPath, FileMode.Open, FileAccess.Read);
    var md5 := new MD5CryptoServiceProvider();
    var mVal := md5.ComputeHash(fs);
    fs.Close;
    var sb := new StringBuilder();
    var i: integer := 0;
    while i < mVal.Length do
    begin
      sb.Append(mVal[i].ToString('x2'));
      inc(i);
    end;
    st := sb.ToString;
  except
    // on System.IO.PathTooLongException do mException := true;
  end;
  // дополнить массив файлов mFilesList
  SetLength(mFilesList, (mFilesList.Length + 1));
  mFilesList[mFilesList.Length - 1].fullpath := mPath;
  mFilesList[mFilesList.Length - 1].namefile := GetFileFolderName(mPath);
  mFilesList[mFilesList.Length - 1].hashpath := GetMixHashes(Arr(st, mFilesList[mFilesList.Length - 1].namefile));
  mFilesList[mFilesList.Length - 1].hashfile := st;
  // результат
  if mCheckNames then Result := mFilesList[mFilesList.Length - 1].hashpath else Result := st;
  // интерфейс
  var mChr: char := chr((mFilesList.Length * 100 / mCountAllFiles).Round + 50);
  UpdateInterface(mChr.ToString + 'xxxxxxxxxxxxxxxx'); // обновление только ProgressBar1
end;

// сканирование папок для хэширования
function Form1.GetHashFolder(mPath: string): string;
var
  mTmpArray: array of string;
begin
  var mCurrListFolders: sequence of string := EnumerateAllDirectories(mPath);
  var mCurrListFiles: sequence of string := EnumerateAllFiles(mPath);
  SetLength(mTmpArray, mCurrListFolders.Count + mCurrListFiles.Count);
  // обработка подпапок в папке mPath
  var m: integer := 0;
  if mCurrListFolders.Count > 0 then
    foreach var fn in mCurrListFolders do
    begin
      inc(m);
      mTmpArray[m - 1] := GetHashFolder(fn.ToString);
      // Application.DoEvents; // разгрузка
    end;
  // обработка файлов в папке mPath
  var n: integer := 0;
  if mCurrListFiles.Count > 0 then 
    foreach var fn in mCurrListFiles do
    begin
      inc(n);
      mTmpArray[m + n - 1] := GetHashFile(fn.ToString);
      // Application.DoEvents; // разгрузка
    end;
  // получение хэша массива mTmpArray (хэш пустой папки = '')
  if mTmpArray.Length = 0 then Result := '' else Result := GetMixHashes(mTmpArray);
end;

// === ПОТОК === процедура поиска хэшей всех найденных папок по списку mMainList
procedure Form1.GetHashesThread;
begin
  // флаг старта потока
  mThreadOn := true;
  // флаг исключения на длинные имена
  // mException := false;
  // заполнение массива папок mMainList (без файлов в начальной папке mMainPatch)
  var i: integer := -1;
  SetLength(mMainList, mFoldersList.Count);
  foreach var fn in mFoldersList do
  begin
    inc(i);
    mMainList[i].index := 0; // до сканирования индексы всех папок = 0 (не имеют дублей)
    mMainList[i].fullpath := fn.ToString;
    mMainList[i].namefolder := GetFileFolderName(fn.ToString);
    mMainList[i].hash := GetHashFolder(fn.ToString);
  end;
  // интерфейс
  var x: integer := SortingFolders(true); // true - первый вызов функции
  var n: string := '0';
  mNameStatusLabel := 'Compare is finished, ';
  if x = 0 then
    mNameStatusLabel := mNameStatusLabel + 'double folders not found!'
  else
  begin
    n := '1';
    mNameStatusLabel := mNameStatusLabel + 'found ' + x.ToString + ' double folders!';
  end;
  // ord(50) -> progressBar1.Value := 0;
  // n = (x > 1) -> if x > 1 then n := 1 else n := 0;
  // вкл/выкл кнопки Export To TXT-File -> if SortingFolders > 1 then i := 1 else i := 0;
  UpdateInterface((chr(50)).ToString + 'x1' + n + n + n + '1x0x1110' + n + '01');
  // флаг завершения потока
  mThreadOn := false;
  // обработка флага исключения на длинные имена
  // if mException and CheckBox1.Checked
  //   then MessageBox(Handle.ToInt32, 'Please, check long names file(s)/folder(s) in selected directory!', 'Warning', 0);
end;

// обновление интерфейса передачей 17-значного кода [123456789abcdefgh]
procedure Form1.UpdateInterface(mString: String);
begin
  // 1 - код символа char от 050 до 150 - заполнение ProgressBar1
  // 2 - если 1, то обновить TextBox1
  // 3 - если 1, то очистить все строки dataGridView1
  // 4 - если 1, то заполнить dataGridView1 массивом из mMainList[i] (index и path)
  // 5 - 1 или 0, вкл/выкл dataGridView1
  // 6 - если 1, то убрать выделенную строку в dataGridView1
  // 7 - если 1, то очистить все строки dataGridView2
  // 8 - если 1, то заполнить dataGridView2 массивом mMainList[k] (ddix и ddir)
  // 9 - 1 или 0, вкл/выкл dataGridView2
  // a - если 1, то убрать выделенную строку в dataGridView2
  // b - 1 или 0, вкл/выкл Button1 - Open Main Folder и CheckBox1
  // c - 1 или 0, вкл/выкл Button2 - Start Compare / Stop Compare
  // d - 1 или 0, текст на Button2 - Start Compare / Stop Compare
  // e - 1 или 0, вкл/выкл Button3 - Pause
  // f - 1 или 0, вкл/выкл Button4 - Export To TXT-File
  // g - 1 или 0, вкл/выкл Button5 - Delete Double Folder(s)
  // h - если 1, то обновить toolStripStatusLabel1
  
  {1} if mString[1] <> 'x' then progressBar1.Value := ord(mString[1]) - 50;
  {2} if mString[2] = '1' then TextBox1.Text := mMainPatch;
  {3} if mString[3] = '1' then dataGridView1.Rows.Clear;
  {4} if mString[4] = '1' then
  begin // заполнение dataGridView1 папками, у которых есть дубли
    var m: integer := mMainList.Length - 1;
    for var i: integer := 0 to m do
      if mMainList[i].index > 0 then // добавлять только папки с ненулевым индексом
        dataGridView1.Rows.Add(mMainList[i].index, mMainList[i].fullpath);
  end;
  {5} case mString[5] of
    '0': dataGridView1.Enabled := false;
    '1': dataGridView1.Enabled := true;
  end;
  {6} if mString[6] = '1' then dataGridView1.ClearSelection;
  {7} if mString[7] = '1' then dataGridView2.Rows.Clear;
  {8} if mString[8] = '1' then
  begin
    // заполнение dataGridView2 папками-дублями выбранной в dataGridView1 папки
    var n: integer := 0;
    var mErr: integer := 0;
    mSelectDD4Delete := -1;
    // зафиксировать выбранный элемент по индексу для удаления его папок-дублей
    val(dataGridView1.CurrentRow.Cells[0].Value.ToString, n, mErr);
    if (mErr = 0) and (n > 0) then
    begin
      var m: integer := mMainList.Length - 1;
      // поиск индекса n в массиве mMainList[i].index
      for var i: integer := 0 to m do
        if mMainList[i].index = n then // добавлять только папки с ненулевым индексом
        begin
          mSelectDD4Delete := i;
          Break; // выход из цикла
        end;  
      // заполнение правой таблицы папками-дублями выбранной папки
      dataGridView2.Rows.Clear; // очистить правую таблицу
      if mMainList[mSelectDD4Delete].ddir.Length > 0 then
      begin
        for var j: integer := 0 to (mMainList[mSelectDD4Delete].ddir.Length - 1) do
          dataGridView2.Rows.Add(mMainList[mSelectDD4Delete].ddix[j], mMainList[mSelectDD4Delete].ddir[j]);
        // интерфейс
        UpdateInterface('xxxxxxxx11xxxxx1x');
      end;
    end;  
  end;
  {9} case mString[9] of
    '0': dataGridView2.Enabled := false;
    '1': dataGridView2.Enabled := true;
  end;
  {a} if mString[10] = '1' then dataGridView2.ClearSelection;
  {b} case mString[11] of
    '0':
      begin
        Button1.Enabled := false;
        CheckBox1.Enabled := false;
      end;
    '1':
      begin
        Button1.Enabled := true;
        CheckBox1.Enabled := true;
      end;
  end;
  {c} case mString[12] of
    '0': Button2.Enabled := false;
    '1': Button2.Enabled := true;
  end;
  {d} case mString[13] of
    '0': Button2.Text := 'Stop Compare';
    '1': Button2.Text := 'Start Compare';
  end;
  {e} case mString[14] of
    '0': Button3.Enabled := false;
    '1': Button3.Enabled := true;
  end;
  {f} case mString[15] of
    '0': Button4.Enabled := false;
    '1': Button4.Enabled := true;
  end;
  {g} case mString[16] of
    '0': Button5.Enabled := false;
    '1': Button5.Enabled := true;
  end;
  {h} if mString[17] = '1' then toolStripStatusLabel1.Text := mNameStatusLabel;
end;

// ... загрузка формы (старт программы)
procedure Form1.Form1_Load(sender: Object; e: EventArgs);
begin
  {
  dataGridView1.Columns[0].SortMode := DataGridViewColumnSortMode.NotSortable;
  dataGridView1.Columns[1].SortMode := DataGridViewColumnSortMode.NotSortable;
  dataGridView2.Columns[0].SortMode := DataGridViewColumnSortMode.NotSortable;
  dataGridView2.Columns[1].SortMode := DataGridViewColumnSortMode.NotSortable;
  }
  {
  dataGridView1.Enabled := true;
  for var i: integer := 0 to 500 do
  dataGridView1.Rows.Add(iToStringjjdfsnbljvdfab;osfjbvojasbvaojsfbvjosdbvdstjneryeasojdfbvzsdbozsdfjbozsjdbzsdbzosdfbzsb');
  dataGridView1.ClearSelection;
  dataGridView1.Enabled := true;
  }
end;

// изменение размеров формы
procedure Form1.Form1_SizeChanged(sender: Object; e: EventArgs);
begin
  var x: integer := Round((Self.Size.Width - 800) / 2) + 376;
  var y: integer := Self.Size.Height - 170;
  DataGridView1.Size := new System.Drawing.Size(x, y);
  DataGridView2.Size := new System.Drawing.Size(x, y);
end;

// инициализация начальной папки 
procedure Form1.button1_Click(sender: Object; e: EventArgs);
begin
  folderBrowserDialog1.ShowDialog;
  mMainPatch := folderBrowserDialog1.SelectedPath; // начальная папка
  if mMainPatch <> '' then 
  begin
    // количество файлов в подпапках начальной папки (без файлов в самой начальной папке)
    mCountAllFiles := EnumerateAllFiles(mMainPatch).Count - EnumerateFiles(mMainPatch).Count;
    // список всех папок в начальной папке, включая вложенные (через последовательность)
    mFoldersList := EnumerateAllDirectories(mMainPatch);
    // интерфейс
    mNameStatusLabel := 'Found ' + mFoldersList.Count.ToString + ' folder(s) and ' + mCountAllFiles.ToString + ' file(s)';
    // вкл/выкл кнопки Start Compare -> if mFoldersList.Count > 1 then i := 1 else i := 0;
    UpdateInterface('x11x0x1x0xx' + (ord(mFoldersList.Count > 1)).ToString + 'x0001');    
  end;  
end;

// сканирование/остановка_сканирования всех папок в начальной папке
procedure Form1.button2_Click(sender: Object; e: EventArgs);
begin
  if mMainPatch <> '' then 
  begin // папка выбрана
    if mThreadOn then // поток запущен
    begin // остановка потока
      // операции
      if mThreadSuspend then mThr.Resume; // если процесс приостановлен, то сначала его надо возобновить
      mThr.Abort; // прерывание потока
      mThr.Join; // ожидание прерывания потока
      mThreadOn := false;
      mThreadSuspend := false;
      // интерфейс
      mNameStatusLabel := 'Process aborted!';
      UpdateInterface((chr(50)).ToString + 'xxxxxxxxx1x10001');
    end
    else
    begin // запуск потока
      // операции
      SetLength(mFilesList, 0); // обнуление массива всех файлов в подпапках начальной папки
      mThr := new Thread(GetHashesThread);
      mThr.Start;
      mThreadOn := true;
      mThreadSuspend := false;
      // интерфейс
      mNameStatusLabel := 'Processed...';
      UpdateInterface('xx1x0x1x0x0x01001');
    end;
  end;
end;

// приостановка/возобновление потока
procedure Form1.button3_Click(sender: Object; e: EventArgs);
begin
  if mThreadOn and mThreadSuspend then
  begin
    mThreadSuspend := false;
    toolStripStatusLabel1.Text := 'Process continued...';
    mThr.Resume;
  end
  else
  begin
    mThreadSuspend := true;
    toolStripStatusLabel1.Text := 'Process paused...';
    mThr.Suspend;
  end;
end;

// сохранение списка папок-дубликатов в текстовый файл
procedure Form1.button4_Click(sender: Object; e: EventArgs);
var
  fg: textfile;
begin
  var d: DateTime := DateTime.Now;
  var str: string := 'list_double_folders_' + d.Hour.ToString('00') + '-' + d.Minute.ToString('00') + '-' + d.Second.ToString('00') + '.txt';
  AssignFile(fg, str);
  Rewrite(fg);
  var m: integer := mMainList.Length - 1;
  for var i: integer := 0 to m do if mMainList[i].index > 0 then Writeln(fg, mMainList[i].hash + ' - ' + mMainList[i].fullpath);
  CloseFile(fg);
  // открытие файла в программе по умолчанию (блокнот)
  System.Diagnostics.Process.Start('notepad', str);
end;

// удаление папок-дубликатов выбранной папки
procedure Form1.button5_Click(sender: Object; e: EventArgs);
begin
  // проверка корректности выбора папки
  if (mSelectDD4Delete = -1) or (mMainList[mSelectDD4Delete].index = 0) then Exit;
  // обработка папок-дублей
  var k: integer := mSelectDD4Delete;
  var b: boolean := false;
  var ddirCount: integer := mMainList[k].ddir.Length - 1;
  for var i: integer := 0 to ddirCount do
  begin
    var str: string := mMainList[k].ddir[i];
    try
      if System.IO.Directory.Exists(str) then System.IO.Directory.Delete(str, true);
    except
      on System.IO.IOException do b := true;
    end;
  end;
  // очистить и отключить обе таблицы
  UpdateInterface('xx1x0x1x0xxxxxxxx');
  // проверка удаления папок-дублей
  if b then
  begin
    MessageBox(Handle.ToInt32, 'Double folder(s) are NOT available for deleting!', 'Warning', 0);
    Exit;    
  end;
  // назначить индекс 0:
  // a) выбранной папке, которая была выбрана в левом списке и которая после удаления папок-дублей осталась в 1 экз.
  // b) удаленным папкам-дублям
  // c) удаленным папкам, которые были вложены в удаленные папки-дубли
  mMainList[k].index := 0; // a)
  mMainList[k].hash := '';
  var m: integer := mMainList.Length - 1;
  // временный массив для поиска вложенных папок-дублей
  var mArray: array of string;
  var mArrayCount: integer := mMainList[k].ddir.Length;
  SetLength(mArray, mArrayCount + 1);
  mArray[0] := mMainList[k].fullpath;
  for var p: integer := 1 to mArrayCount do mArray[p] := mMainList[k].ddir[p - 1];
  // поиск в mMainList папок-дублей из подсписка mMainList[k].ddir включая вложенные
  for var j: integer := 0 to m do
    for var i: integer := 0 to mArrayCount do
      if (mMainList[j].index > 0) and
         (pos(mArray[i], mMainList[j].fullpath) > 0) // вкл. mMainList[k].ddir[i] = mMainList[j].path
      then
      begin
        mMainList[j].index := 0; // b)
        mMainList[j].hash := ''; // обнулить хэш у удаленных папок-дублей (включая вложенные)
      end;
  // интерфейс
  var x: integer := SortingFolders(false);
  var n: string := '0';
  mNameStatusLabel := 'Compare is finished, ';
  if x = 0 then
    mNameStatusLabel := mNameStatusLabel + 'double folders not found!'
  else 
  begin
    n := '1';
    mNameStatusLabel := mNameStatusLabel + 'found ' + x.ToString + ' double folders!';
  end;  
  // n = (x > 1) -> if x > 1 then n := 1 else n := 0;
  // вкл/выкл кнопки Export To TXT-File -> if SortingFolders > 1 then i := 1 else i := 0;
  UpdateInterface('xx1' + n + n + n + '1x0xxxxx' + n + '01');
end;

// стрелки на клавиатуре - выбор строки в левой таблице
procedure Form1.dataGridView1_KeyUp(sender: Object; e: KeyEventArgs);
begin
  //if e.KeyCode = Keys.Delete then // клавиша Delete
  //  button5_Click(Self, nil)
  //else
    UpdateInterface('xxxxxxx1xxxxxxxxx');
end;

// стрелки на клавиатуре - выбор строки в левой таблице
procedure Form1.dataGridView1_KeyDown(sender: Object; e: KeyEventArgs);
begin
  UpdateInterface('xxxxxxx1xxxxxxxxx');
end;

// клик - выбор строки в левой таблице
procedure Form1.dataGridView1_CellMouseUp(sender: Object; e: DataGridViewCellMouseEventArgs);
begin
  if e.RowIndex <> -1 then UpdateInterface('xxxxxxx1xxxxxxxxx');
end;

// двойной клик в левой таблице - открыть папку в проводнике
procedure Form1.dataGridView1_CellMouseDoubleClick(sender: Object; e: DataGridViewCellMouseEventArgs);
begin
  if e.RowIndex <> -1 then
  begin
    var str: string := dataGridView1.CurrentRow.Cells[1].Value.ToString;
    if System.IO.Directory.Exists(str) then System.Diagnostics.Process.Start(str);
  end;
end;

// двойной клик в правой таблице - открыть папку-дубликат в проводнике
procedure Form1.dataGridView2_CellMouseDoubleClick(sender: Object; e: DataGridViewCellMouseEventArgs);
begin
  if e.RowIndex <> -1 then
  begin
    var str: string := dataGridView2.CurrentRow.Cells[1].Value.ToString;
    if System.IO.Directory.Exists(str) then System.Diagnostics.Process.Start(str);
  end;
end;

// опция проверки соответствия имен файлов/папок
procedure Form1.checkBox1_CheckedChanged(sender: Object; e: EventArgs);
begin
  mCheckNames := CheckBox1.Checked;
end;

end.