extends Control

onready var start_stop_button = $VBoxContainer/ButtonContainer/StartStop
onready var reset_button = $VBoxContainer/ButtonContainer/Reset
onready var time_container = $VBoxContainer/TimeContainer
onready var countdown_timer = $CountdownTimer
onready var countdown = $VBoxContainer/Countdown
onready var sessionLabel = $VBoxContainer/SessionLabel
onready var workingSession = $VBoxContainer/TimeContainer/WorkingTimeContainer/WorkingTime
onready var breakSession = $VBoxContainer/TimeContainer/BreakTimeContainer/BreakTime
onready var longBreakTime = $VBoxContainer/TimeContainer/LongBreakContainer/LongBreakTime
onready var numCycles = $VBoxContainer/TimeContainer/NumWorkingSessionContainer/NumWorkingSessions
onready var rainEnabled = $VBoxContainer/TimeContainer/CheckButton

# Track the number of seconds remaining
var countdown_seconds : int = 0
# Track whether or not the timer has been set
var is_timer_set := false
var is_running := false
var is_break := false
var session_count : int = 1

func _ready() -> void:
	workingSession.add_item("20 minutes", 20)
	workingSession.add_item("25 minutes", 25)
	workingSession.add_item("30 minutes", 30)
	workingSession.add_item("45 minutes", 45)
	workingSession.add_item("60 minutes", 60)
	workingSession.select(1)
	breakSession.add_item("3 minutes", 3)
	breakSession.add_item("5 minutes", 5)
	breakSession.add_item("10 minutes", 10)
	breakSession.add_item("15 minutes", 15)
	breakSession.select(1)
	longBreakTime.add_item("10 minutes", 10)
	longBreakTime.add_item("15 minutes", 15)
	longBreakTime.add_item("20 minutes", 20)
	longBreakTime.add_item("30 minutes", 30)
	longBreakTime.select(1)
	numCycles.add_item("3", 3)
	numCycles.add_item("4", 4)
	numCycles.add_item("5", 5)
	numCycles.select(1)
	

func _process(_delta: float) -> void:
	if is_running:
		_get_time()

func _get_time() -> void:
	var time_left := int(countdown_timer.get_time_left())
	var seconds := time_left % 60
	var hours := time_left / 3600
	var minutes := (time_left - (3600 * hours)) / 60
	
	countdown.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _on_StartStop_pressed() -> void:
	if !is_running:
		is_running = true
		reset_button.visible = false
		start_stop_button.text = "PAUSE"
		if !is_timer_set:
			countdown_seconds = workingSession.get_selected_id() * 60
			time_container.visible = false
			sessionLabel.visible = true
			sessionLabel.text = "SESSION 1"
			countdown.visible = true
			is_timer_set = true
		countdown_timer.wait_time = countdown_seconds
		countdown_timer.start()
		if rainEnabled && $RainSound.stream_paused:
			$RainSound.stream_paused = false
		elif rainEnabled:
			$RainSound.play()
	else:
		is_running = false
		reset_button.visible = true
		start_stop_button.text = "RESUME"
		countdown_seconds = int(countdown_timer.time_left)
		countdown_timer.stop()
		if rainEnabled:
			$RainSound.stream_paused = true

func _handle_reset() -> void:
	is_timer_set = false
	is_running = false
	reset_button.visible = false
	sessionLabel.visible = false
	countdown.visible = false
	time_container.visible = true
	start_stop_button.text = "START"
	sessionLabel.text = "SESSION 1"
	session_count = 1
	is_break = false
	$RainSound.stop()

func _on_CountdownTimer_timeout() -> void:
	if is_break:
		session_count += 1
		sessionLabel.text = "SESSION %d" % [session_count]
		countdown_seconds = workingSession.get_selected_id() * 60
	elif session_count % numCycles.get_selected_id() == 0:
		sessionLabel.text = "LONG BREAK %d" % [session_count / numCycles.get_selected_id()]
		countdown_seconds = longBreakTime.get_selected_id() * 60
	else:
		sessionLabel.text = "BREAK %d" % [session_count]
		countdown_seconds = breakSession.get_selected_id() * 60
	is_break = !is_break
	countdown_timer.wait_time = countdown_seconds
	countdown_timer.start()
	$Alarm.play()

func _on_Reset_pressed() -> void:
	_handle_reset()
