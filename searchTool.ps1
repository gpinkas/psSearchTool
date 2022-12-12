# Search tool
# code inpired from https://www.benecke.cloud/powershell-how-to-build-a-gui-with-visual-studio/

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:TestPowershellGui"
        Title="SearchTool" MinHeight="240" Height="600" MinWidth="400" Width="800">
	<Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="120" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>
        <Grid Grid.Row="0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="100"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Label Content="Path" HorizontalAlignment="Left" Height="28" Margin="10,10,0,0" VerticalAlignment="Top" Width="80"/>
            <Label Content="File Pattern" HorizontalAlignment="Left" Height="28" Margin="10,43,0,0" VerticalAlignment="Top" Width="80"/>
            <Label Content="Text Pattern" HorizontalAlignment="Left" Height="28" Margin="10,76,0,0" VerticalAlignment="Top" Width="80"/>
            <TextBox Name="inputPath" Grid.Column="1" Height="28" Margin="0,10,57,0" TextWrapping="Wrap" VerticalAlignment="Top"/>
            <TextBox Name="inputFilePattern" Grid.Column="1" Height="28" Margin="0,43,57,0" TextWrapping="Wrap" Text="*.*" VerticalAlignment="Top"/>
            <TextBox Name="inputTextPattern" Grid.Column="1" Height="28" Margin="0,76,57,0" TextWrapping="Wrap" VerticalAlignment="Top"/>
            <Button Name="btnSelectPath" Grid.Column="1" Content="..." HorizontalAlignment="Right" Height="28" Margin="0,10,10,0" VerticalAlignment="Top" Width="42"/>
            <Button Name="btnSearch" Grid.Column="1" Content="Go" HorizontalAlignment="Right" Height="57" Margin="0,47,10,0" VerticalAlignment="Top" Width="42"/>
        </Grid>
        <Grid Grid.Row="1">
            <ListBox Name="listResults" Margin="10,0,10,10"/>
        </Grid>
    </Grid>
</Window>
"@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load($reader)}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}

# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

# add support
$dlgPathBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

#Assign system variables
$inputFilePattern.text = "*.*"
$inputTextPattern.text = ""

#Assign events
$btnSelectPath.Add_Click({
	$dlgPathBrowser.ShowDialog() | out-null
	$inputPath.text = $dlgPathBrowser.SelectedPath
})

$btnSearch.Add_Click({
#	$textResults.text = "start"
	$listResults.ItemsSource = Get-ChildItem $inputPath.text -Filter $inputFilePattern.text -Recurse | Select-String -Pattern $inputTextPattern.text
#	$textResults.text = "done"
})

#Show Form
$Form.ShowDialog() | out-null
