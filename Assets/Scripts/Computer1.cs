using UnityEngine;

public class Computer1 : MonoBehaviour
{
    public static Computer1 Instance;

    public GameObject uiPanel; // assign in Inspector
    private bool playerInZone = false;

    void Awake()
    {
        Instance = this;
    }

    void Update()
    {
        

        if (playerInZone && Input.GetKeyDown(KeyCode.E))
        {
            // Toggle the UI panel
            uiPanel.SetActive(!uiPanel.activeSelf);
            Debug.Log("Toggled UI!");

            // Play or stop audio depending on UI state
            if (uiPanel.activeSelf && playerInZone)
            {
                if (PauseManager.IsPaused) return;
                ComputerAudioManager.Instance.PlaySound("ComputerSound");
                Debug.Log("Audiomanager running");
            }
            else
            {
                ComputerAudioManager.Instance.StopSound("ComputerSound");
            }
            
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = true;
            Debug.Log("Player entered zone");
        }
    }

    void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            playerInZone = false;
            uiPanel.SetActive(false);
            Debug.Log("Player left zone");
        }
    }

    public void CloseComputerUI()
    {
        if (uiPanel.activeSelf)
        {
            uiPanel.SetActive(false);
            ComputerAudioManager.Instance.StopSound("ComputerSound");
            Debug.Log("Computer UI closed by external event");
        }
    }
}
