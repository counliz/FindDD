procedure InitializeComponent;
    begin
        self.button1 := new System.Windows.Forms.Button();
        self.textBox1 := new System.Windows.Forms.TextBox();
        self.button2 := new System.Windows.Forms.Button();
        self.button3 := new System.Windows.Forms.Button();
        self.button4 := new System.Windows.Forms.Button();
        self.button5 := new System.Windows.Forms.Button();
        self.dataGridView1 := new System.Windows.Forms.DataGridView();
        self.Column1 := new System.Windows.Forms.DataGridViewTextBoxColumn();
        self.Column2 := new System.Windows.Forms.DataGridViewTextBoxColumn();
        self.dataGridView2 := new System.Windows.Forms.DataGridView();
        self.Column3 := new System.Windows.Forms.DataGridViewTextBoxColumn();
        self.Column4 := new System.Windows.Forms.DataGridViewTextBoxColumn();
        self.progressBar1 := new System.Windows.Forms.ProgressBar();
        self.statusStrip1 := new System.Windows.Forms.StatusStrip();
        self.toolStripStatusLabel1 := new System.Windows.Forms.ToolStripStatusLabel();
        self.folderBrowserDialog1 := new System.Windows.Forms.FolderBrowserDialog();
        self.checkBox1 := new System.Windows.Forms.CheckBox();
        (System.ComponentModel.ISupportInitialize(self.dataGridView1)).BeginInit();
        (System.ComponentModel.ISupportInitialize(self.dataGridView2)).BeginInit();
        self.statusStrip1.SuspendLayout();
        self.SuspendLayout();
        // 
        // button1
        // 
        self.button1.Location := new System.Drawing.Point(12, 12);
        self.button1.Name := 'button1';
        self.button1.Size := new System.Drawing.Size(185, 23);
        self.button1.TabIndex := 0;
        self.button1.Text := 'Open Main Folder';
        self.button1.UseVisualStyleBackColor := true;
        self.button1.Click += button1_Click;
        // 
        // textBox1
        // 
        self.textBox1.Anchor := (System.Windows.Forms.AnchorStyles(((System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left) 
                    or System.Windows.Forms.AnchorStyles.Right)));
        self.textBox1.Enabled := false;
        self.textBox1.Location := new System.Drawing.Point(203, 12);
        self.textBox1.Name := 'textBox1';
        self.textBox1.ReadOnly := true;
        self.textBox1.Size := new System.Drawing.Size(567, 22);
        self.textBox1.TabIndex := 1;
        // 
        // button2
        // 
        self.button2.Enabled := false;
        self.button2.Location := new System.Drawing.Point(12, 41);
        self.button2.Name := 'button2';
        self.button2.Size := new System.Drawing.Size(185, 23);
        self.button2.TabIndex := 2;
        self.button2.Text := 'Start Compare';
        self.button2.UseVisualStyleBackColor := true;
        self.button2.Click += button2_Click;
        // 
        // button3
        // 
        self.button3.Enabled := false;
        self.button3.Location := new System.Drawing.Point(12, 70);
        self.button3.Name := 'button3';
        self.button3.Size := new System.Drawing.Size(185, 23);
        self.button3.TabIndex := 3;
        self.button3.Text := 'Pause';
        self.button3.UseVisualStyleBackColor := true;
        self.button3.Click += button3_Click;
        // 
        // button4
        // 
        self.button4.Anchor := System.Windows.Forms.AnchorStyles.Top;
        self.button4.Enabled := false;
        self.button4.Location := new System.Drawing.Point(585, 70);
        self.button4.Name := 'button4';
        self.button4.Size := new System.Drawing.Size(185, 23);
        self.button4.TabIndex := 4;
        self.button4.Text := 'Export To TXT-File';
        self.button4.UseVisualStyleBackColor := true;
        self.button4.Click += button4_Click;
        // 
        // button5
        // 
        self.button5.Anchor := System.Windows.Forms.AnchorStyles.Top;
        self.button5.Enabled := false;
        self.button5.Location := new System.Drawing.Point(394, 70);
        self.button5.Name := 'button5';
        self.button5.Size := new System.Drawing.Size(185, 23);
        self.button5.TabIndex := 5;
        self.button5.Text := 'Delete Double Folders';
        self.button5.UseVisualStyleBackColor := true;
        self.button5.Click += button5_Click;
        // 
        // dataGridView1
        // 
        self.dataGridView1.AllowUserToAddRows := false;
        self.dataGridView1.AllowUserToDeleteRows := false;
        self.dataGridView1.AllowUserToResizeColumns := false;
        self.dataGridView1.AllowUserToResizeRows := false;
        self.dataGridView1.Anchor := (System.Windows.Forms.AnchorStyles(((System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Bottom) 
                    or System.Windows.Forms.AnchorStyles.Left)));
        self.dataGridView1.AutoSizeColumnsMode := System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
        self.dataGridView1.BackgroundColor := System.Drawing.SystemColors.Control;
        self.dataGridView1.ColumnHeadersHeightSizeMode := System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
        self.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[2](self.Column1, self.Column2));
        self.dataGridView1.Enabled := false;
        self.dataGridView1.Location := new System.Drawing.Point(12, 98);
        self.dataGridView1.MultiSelect := false;
        self.dataGridView1.Name := 'dataGridView1';
        self.dataGridView1.ReadOnly := true;
        self.dataGridView1.RowHeadersVisible := false;
        self.dataGridView1.RowHeadersWidth := 51;
        self.dataGridView1.RowHeadersWidthSizeMode := System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
        self.dataGridView1.RowTemplate.Height := 24;
        self.dataGridView1.RowTemplate.Resizable := System.Windows.Forms.DataGridViewTriState.False;
        self.dataGridView1.ScrollBars := System.Windows.Forms.ScrollBars.Vertical;
        self.dataGridView1.SelectionMode := System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
        self.dataGridView1.Size := new System.Drawing.Size(376, 230);
        self.dataGridView1.TabIndex := 6;
        self.dataGridView1.CellMouseDoubleClick += dataGridView1_CellMouseDoubleClick;
        self.dataGridView1.CellMouseUp += dataGridView1_CellMouseUp;
        self.dataGridView1.KeyDown += dataGridView1_KeyDown;
        self.dataGridView1.KeyUp += dataGridView1_KeyUp;
        // 
        // Column1
        // 
        self.Column1.AutoSizeMode := System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
        self.Column1.FillWeight := 32;
        self.Column1.HeaderText := 'Index';
        self.Column1.MinimumWidth := 6;
        self.Column1.Name := 'Column1';
        self.Column1.ReadOnly := true;
        self.Column1.SortMode := System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
        self.Column1.Width := 66;
        // 
        // Column2
        // 
        self.Column2.FillWeight := 150;
        self.Column2.HeaderText := 'Paths all folders -- double click to open';
        self.Column2.MinimumWidth := 6;
        self.Column2.Name := 'Column2';
        self.Column2.ReadOnly := true;
        self.Column2.SortMode := System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
        // 
        // dataGridView2
        // 
        self.dataGridView2.AllowUserToAddRows := false;
        self.dataGridView2.AllowUserToDeleteRows := false;
        self.dataGridView2.AllowUserToResizeColumns := false;
        self.dataGridView2.AllowUserToResizeRows := false;
        self.dataGridView2.Anchor := (System.Windows.Forms.AnchorStyles((System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Bottom)));
        self.dataGridView2.AutoSizeColumnsMode := System.Windows.Forms.DataGridViewAutoSizeColumnsMode.Fill;
        self.dataGridView2.BackgroundColor := System.Drawing.SystemColors.Control;
        self.dataGridView2.ColumnHeadersHeightSizeMode := System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
        self.dataGridView2.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[2](self.Column3, self.Column4));
        self.dataGridView2.Enabled := false;
        self.dataGridView2.Location := new System.Drawing.Point(394, 98);
        self.dataGridView2.MultiSelect := false;
        self.dataGridView2.Name := 'dataGridView2';
        self.dataGridView2.ReadOnly := true;
        self.dataGridView2.RowHeadersVisible := false;
        self.dataGridView2.RowHeadersWidth := 51;
        self.dataGridView2.RowHeadersWidthSizeMode := System.Windows.Forms.DataGridViewRowHeadersWidthSizeMode.DisableResizing;
        self.dataGridView2.RowTemplate.Height := 24;
        self.dataGridView2.RowTemplate.Resizable := System.Windows.Forms.DataGridViewTriState.False;
        self.dataGridView2.ScrollBars := System.Windows.Forms.ScrollBars.Vertical;
        self.dataGridView2.SelectionMode := System.Windows.Forms.DataGridViewSelectionMode.FullRowSelect;
        self.dataGridView2.Size := new System.Drawing.Size(376, 230);
        self.dataGridView2.TabIndex := 7;
        self.dataGridView2.CellMouseDoubleClick += dataGridView2_CellMouseDoubleClick;
        // 
        // Column3
        // 
        self.Column3.AutoSizeMode := System.Windows.Forms.DataGridViewAutoSizeColumnMode.None;
        self.Column3.FillWeight := 32;
        self.Column3.HeaderText := 'Index';
        self.Column3.MinimumWidth := 6;
        self.Column3.Name := 'Column3';
        self.Column3.ReadOnly := true;
        self.Column3.SortMode := System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
        self.Column3.Width := 60;
        // 
        // Column4
        // 
        self.Column4.FillWeight := 167.914459;
        self.Column4.HeaderText := 'Path(s) double folder(s) -- double click to open';
        self.Column4.MinimumWidth := 6;
        self.Column4.Name := 'Column4';
        self.Column4.ReadOnly := true;
        self.Column4.SortMode := System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
        // 
        // progressBar1
        // 
        self.progressBar1.Anchor := (System.Windows.Forms.AnchorStyles(((System.Windows.Forms.AnchorStyles.Top or System.Windows.Forms.AnchorStyles.Left) 
                    or System.Windows.Forms.AnchorStyles.Right)));
        self.progressBar1.Location := new System.Drawing.Point(203, 40);
        self.progressBar1.Name := 'progressBar1';
        self.progressBar1.Size := new System.Drawing.Size(567, 23);
        self.progressBar1.TabIndex := 8;
        // 
        // statusStrip1
        // 
        self.statusStrip1.ImageScalingSize := new System.Drawing.Size(20, 20);
        self.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[1](self.toolStripStatusLabel1));
        self.statusStrip1.Location := new System.Drawing.Point(0, 327);
        self.statusStrip1.Name := 'statusStrip1';
        self.statusStrip1.Size := new System.Drawing.Size(782, 26);
        self.statusStrip1.TabIndex := 9;
        self.statusStrip1.Text := 'statusStrip1';
        // 
        // toolStripStatusLabel1
        // 
        self.toolStripStatusLabel1.Name := 'toolStripStatusLabel1';
        self.toolStripStatusLabel1.Size := new System.Drawing.Size(50, 20);
        self.toolStripStatusLabel1.Text := 'Ready';
        // 
        // checkBox1
        // 
        self.checkBox1.Location := new System.Drawing.Point(203, 70);
        self.checkBox1.Name := 'checkBox1';
        self.checkBox1.Size := new System.Drawing.Size(185, 23);
        self.checkBox1.TabIndex := 10;
        self.checkBox1.Text := 'Must Match All Name(s)';
        self.checkBox1.UseVisualStyleBackColor := true;
        self.checkBox1.CheckedChanged += checkBox1_CheckedChanged;
        // 
        // Form1
        // 
        self.ClientSize := new System.Drawing.Size(782, 353);
        self.Controls.Add(self.checkBox1);
        self.Controls.Add(self.statusStrip1);
        self.Controls.Add(self.progressBar1);
        self.Controls.Add(self.dataGridView2);
        self.Controls.Add(self.dataGridView1);
        self.Controls.Add(self.button5);
        self.Controls.Add(self.button4);
        self.Controls.Add(self.button3);
        self.Controls.Add(self.button2);
        self.Controls.Add(self.textBox1);
        self.Controls.Add(self.button1);
        self.MinimumSize := new System.Drawing.Size(800, 400);
        self.Name := 'Form1';
        self.StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen;
        self.Text := 'Find Double Directories 1.0 (2023)';
        self.Load += Form1_Load;
        self.SizeChanged += Form1_SizeChanged;
        (System.ComponentModel.ISupportInitialize(self.dataGridView1)).EndInit();
        (System.ComponentModel.ISupportInitialize(self.dataGridView2)).EndInit();
        self.statusStrip1.ResumeLayout(false);
        self.statusStrip1.PerformLayout();
        self.ResumeLayout(false);
        self.PerformLayout();
    end;
