using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Tilemaps;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [HideInInspector] public bool disableOnExit = false;
    [SerializeField] private GameObject youEscapedUI;
    #region Variables
    [Header("Door Settings")]
    [SerializeField] private GameObject closedDoorTilemap;   // your default closed door tilemap
    [SerializeField] private GameObject openedDoorTilemap;   // your open door tilemap (disabled at start)
    [SerializeField] private GameObject escapeInteractionZone; // the area that ends the game (disabled at start)
    public AudioSource doorAudio; // assign in Inspector

    [Header("Ending Slides")]
    [SerializeField] private List<CanvasGroup> endingSlides; // assign slides in order
    [SerializeField] private float fadeDuration = 1f;
    [SerializeField] private float stayDuration = 1.5f;



    private bool doorUnlocked = false;

    private Questions[] _questions = null;
    public Questions[] QuestionList { get { return _questions; } }

    [SerializeField] GameEvents events = null;

    //[SerializeField] Animator timerAnimtor = null;
    //[SerializeField] TextMeshProUGUI timerText = null;
    [SerializeField] Color timerHalfWayOutColor = Color.yellow;
    [SerializeField] Color timerAlmostOutColor = Color.red;
    private Color timerDefaultColor = Color.white;

    private List<AnswerData> PickedAnswers = new List<AnswerData>();
    private List<int> FinishedQuestions = new List<int>();
    private int currentQuestion = 0;

    private int timerStateParaHash = 0;

    private IEnumerator IE_WaitTillNextRound = null;
    //private IEnumerator IE_StartTimer = null;

    private bool IsFinished
    {
        get
        {
            return (FinishedQuestions.Count < QuestionList.Length) ? false : true;
        }

    }

    #endregion

    #region Default Unity methods

    /// <summary>
    /// Function that is called when the object becomes enabled and active
    /// </summary>
    void OnEnable()
    {
        events.UpdateQuestionAnswer += UpdateAnswers;
    }
    /// <summary>
    /// Function that is called when the behaviour becomes disabled
    /// </summary>
    void OnDisable()
    {
        events.UpdateQuestionAnswer -= UpdateAnswers;
    }

    /// <summary>
    /// Function that is called on the frame when a script is enabled just before any of the Update methods are called the first time.
    /// </summary>
    void Awake()
    {
        events.CurrentFinalScore = 0;
    }
    /// <summary>
    /// Function that is called when the script instance is being loaded.
    /// </summary>
    void Start()
    {
        events.StartupHighscore = PlayerPrefs.GetInt(GameUtility.SavePrefKey);

        //timerDefaultColor = timerText.color;
        LoadQuestions();

        timerStateParaHash = Animator.StringToHash("TimerState");

        var seed = UnityEngine.Random.Range(int.MinValue, int.MaxValue);
        UnityEngine.Random.InitState(seed);

        Display();
    }

    #endregion

    /// <summary>
    /// Function that is called to update new selected answer.
    /// </summary>
    public void UpdateAnswers(AnswerData newAnswer)
    {
        if (QuestionList[currentQuestion].GetAnswerType == Questions.AnswerType.Single)
        {
            foreach (var answer in PickedAnswers)
            {
                if (answer != newAnswer)
                {
                    answer.Reset();
                }
            }
            PickedAnswers.Clear();
            PickedAnswers.Add(newAnswer);
        }
        else
        {
            bool alreadyPicked = PickedAnswers.Exists(x => x == newAnswer);
            if (alreadyPicked)
            {
                PickedAnswers.Remove(newAnswer);
            }
            else
            {
                PickedAnswers.Add(newAnswer);
            }
        }
    }

    /// <summary>
    /// Function that is called to clear PickedAnswers list.
    /// </summary>
    public void EraseAnswers()
    {
        PickedAnswers = new List<AnswerData>();
    }

    /// <summary>
    /// Function that is called to display new question.
    /// </summary>
    void Display()
    {
        EraseAnswers();
        var question = GetRandomQuestion();

        if (events.UpdateQuestionUI != null)
        {
            events.UpdateQuestionUI(question);
        }
        else { Debug.LogWarning("Ups! Something went wrong while trying to display new Question UI Data. GameEvents.UpdateQuestionUI is null. Issue occured in GameManager.Display() method."); }

        /*if (question.UseTimer)
        {
            UpdateTimer(question.UseTimer);
        }*/
    }

    /// <summary>
    /// Function that is called to accept picked answers and check/display the result.
    /// </summary>
    public void Accept()
    {
        // Skip if no answer has been picked
        if (PickedAnswers.Count == 0)
        {
            Debug.Log("Accept() skipped — no answer picked yet.");
            return;
        }

        bool isCorrect = CheckAnswers();
        FinishedQuestions.Add(currentQuestion);

        UpdateScore((isCorrect) ? QuestionList[currentQuestion].AddScore : -QuestionList[currentQuestion].AddScore);

        if (IsFinished)
        {
            SetHighscore();
            DisableAllComputers();
        }

        var type
            = (IsFinished)
            ? UIManager.ResolutionScreenType.Finish
            : (isCorrect) ? UIManager.ResolutionScreenType.Correct
            : UIManager.ResolutionScreenType.Incorrect;

        if (events.DisplayResolutionScreen != null)
        {
            events.DisplayResolutionScreen(type, QuestionList[currentQuestion].AddScore);
        }

        // Only play SFX for actual submissions
        ComputerAudioManager.Instance.PlaySound(
            (isCorrect) ? "CorrectSFX" : "IncorrectSFX",
            true // bypass UI check
        );

        if (type != UIManager.ResolutionScreenType.Finish)
        {
            if (IE_WaitTillNextRound != null)
            {
                StopCoroutine(IE_WaitTillNextRound);
            }
            IE_WaitTillNextRound = WaitTillNextRound();
            StartCoroutine(IE_WaitTillNextRound);
        }
    }



    #region Timer Methods

    /*void UpdateTimer(bool state)
    {
        switch (state)
        {
            case true:
                IE_StartTimer = StartTimer();
                StartCoroutine(IE_StartTimer);

                timerAnimtor.SetInteger(timerStateParaHash, 2);
                break;
            case false:
                if (IE_StartTimer != null)
                {
                    StopCoroutine(IE_StartTimer);
                }

                timerAnimtor.SetInteger(timerStateParaHash, 1);
                break;
        }
    }*/
    /*IEnumerator StartTimer()
    {
        var totalTime = QuestionList[currentQuestion].Timer;
        var timeLeft = totalTime;

        timerText.color = timerDefaultColor;
        while (timeLeft > 0)
        {
            timeLeft--;

            //AudioManager.Instance.PlaySound("CountdownSFX");

            if (timeLeft < totalTime / 2 && timeLeft > totalTime / 4)
            {
                timerText.color = timerHalfWayOutColor;
            }
            if (timeLeft < totalTime / 4)
            {
                timerText.color = timerAlmostOutColor;
            }

            timerText.text = timeLeft.ToString();
            yield return new WaitForSeconds(1.0f);
        }
        Accept();
    }*/
    IEnumerator WaitTillNextRound()
    {
        yield return new WaitForSeconds(GameUtility.ResolutionDelayTime);
        Display();
    }

    #endregion

    /// <summary>
    /// Function that is called to check currently picked answers and return the result.
    /// </summary>
    bool CheckAnswers()
    {
        if (!CompareAnswers())
        {
            return false;
        }
        return true;
    }
    /// <summary>
    /// Function that is called to compare picked answers with question correct answers.
    /// </summary>
    bool CompareAnswers()
    {
        if (PickedAnswers.Count > 0)
        {
            List<int> c = QuestionList[currentQuestion].GetCorrectAnswer();
            List<int> p = PickedAnswers.Select(x => x.AnswerIndex).ToList();

            var f = c.Except(p).ToList();
            var s = p.Except(c).ToList();

            return !f.Any() && !s.Any();
        }
        return false;
    }

    /// <summary>
    /// Function that is called to load all questions from the Resource folder.
    /// </summary>
    void LoadQuestions()
    {
        Object[] objs = Resources.LoadAll("Questions", typeof(Questions));
        _questions = new Questions[objs.Length];
        for (int i = 0; i < objs.Length; i++)
        {
            _questions[i] = (Questions)objs[i];
        }
    }

    /// <summary>
    /// Function that is called restart the game.
    /// </summary>
    public void RestartGame()
    {
        Debug.Log("HEEEEEEEEEE");
        events.CurrentFinalScore = 0;
        FinishedQuestions.Clear();
        PickedAnswers.Clear();

        // Reload questions just in case (optional)
        LoadQuestions();

        // Reset the quiz UI
        Display();
    }
    /// <summary>
    /// Function that is called to quit the application.
    /// </summary>
    public void QuitGame()
    {
        Application.Quit();
    }

    /// <summary>
    /// Function that is called to set new highscore if game score is higher.
    /// </summary>
    private void SetHighscore()
    {
        var highscore = PlayerPrefs.GetInt(GameUtility.SavePrefKey);
        if (highscore < events.CurrentFinalScore)
        {
            PlayerPrefs.SetInt(GameUtility.SavePrefKey, events.CurrentFinalScore);
        }
    }
    /// <summary>
    /// Function that is called update the score and update the UI.
    /// </summary>
    private void UpdateScore(int add)
    {
        events.CurrentFinalScore += add;

        if (events.ScoreUpdated != null)
        {
            events.ScoreUpdated();
        }
        if (events.CurrentFinalScore >= 100)
        {
            UnlockDoor();
        }
    }

    public void UnlockDoor()
    {
        doorUnlocked = true;

        if (closedDoorTilemap != null)
            closedDoorTilemap.SetActive(false);

        if (openedDoorTilemap != null)
            openedDoorTilemap.SetActive(true);

        if (escapeInteractionZone != null)
            escapeInteractionZone.SetActive(true);

        // Play the door audio
        if (doorAudio != null)
            doorAudio.Play();

        Debug.Log("Door opened and escape zone activated!");
    }

    #region Getters

    Questions GetRandomQuestion()
    {
        var randomIndex = GetRandomQuestionIndex();
        currentQuestion = randomIndex;

        return QuestionList[currentQuestion];
    }
    int GetRandomQuestionIndex()
    {
        var random = 0;
        if (FinishedQuestions.Count < QuestionList.Length)
        {
            do
            {
                random = UnityEngine.Random.Range(0, QuestionList.Length);
            } while (FinishedQuestions.Contains(random) || random == currentQuestion);
        }
        return random;
    }

    public void PlayerWins()
    {
        Debug.Log("Player has won the game!");

        // Pause gameplay
        Time.timeScale = 0f;

        // Start fade-to-white coroutine
        StartCoroutine(FadeToOutroScene("OutroScene", 1.5f));
    }

    private IEnumerator FadeToOutroScene(string outroSceneName, float duration)
    {
        Debug.Log("[GameManager] Preparing white fade overlay...");

        // Create a full-screen UI overlay for fade
        GameObject fadeRoot = new GameObject("SceneFadeRoot");
        Canvas canvas = fadeRoot.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 999;

        fadeRoot.AddComponent<CanvasScaler>();
        fadeRoot.AddComponent<GraphicRaycaster>();

        // Create a white image filling the screen
        GameObject fadeImageObj = new GameObject("FadeImage", typeof(RectTransform));
        fadeImageObj.transform.SetParent(fadeRoot.transform, false);
        UnityEngine.UI.Image fadeImage = fadeImageObj.AddComponent<UnityEngine.UI.Image>();
        fadeImage.color = new Color(1f, 1f, 1f, 0f); // white but transparent

        RectTransform rt = fadeImageObj.GetComponent<RectTransform>();
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.offsetMin = Vector2.zero;
        rt.offsetMax = Vector2.zero;

        Debug.Log("[GameManager] Starting fade to white...");

        float t = 0f;
        while (t < duration)
        {
            t += Time.unscaledDeltaTime; // works even while paused
            float alpha = Mathf.Clamp01(t / duration);
            fadeImage.color = new Color(1f, 1f, 1f, alpha);
            yield return null;
        }

        // Ensure fully white
        fadeImage.color = Color.white;

        Debug.Log("[GameManager] Fade complete. Loading OutroScene...");

        // Unpause before switching scenes
        Time.timeScale = 1f;

        // Load the outro scene
        SceneManager.LoadScene(outroSceneName);
    }


    private void DisableAllComputers()
    {
        disableOnExit = true;
    }


    #endregion
}