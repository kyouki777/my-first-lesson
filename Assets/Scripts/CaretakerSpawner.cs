using UnityEngine;
using System.Collections;

public class CaretakerSpawner : MonoBehaviour
{
    public GameObject caretakerPrefab;
    public Transform[] spawnPoints;
    public Transform player;

    private GameObject currentCaretaker;

    void Start()
    {
        StartCoroutine(SpawnOnceAfterDelay());
    }

    IEnumerator SpawnOnceAfterDelay()
    {
        float wait = Random.Range(300f, 600f);//(300f, 600f); // delay before spawn
        yield return new WaitForSeconds(wait);

        SpawnCaretaker();
    }

    void SpawnCaretaker()
    {
        if (currentCaretaker != null)
            Destroy(currentCaretaker);

        Transform spawn = spawnPoints[Random.Range(0, spawnPoints.Length)];
        currentCaretaker = Instantiate(caretakerPrefab, spawn.position, Quaternion.identity);

        PlayerHeartbeat heartbeat = player.GetComponent<PlayerHeartbeat>();
        if (heartbeat != null)
        {
            heartbeat.caretaker = currentCaretaker.transform;
            Debug.Log("Heartbeat is now tracking: " + currentCaretaker.name);
        }

        var ai = currentCaretaker.GetComponent<CaretakerAI>();
        if (ai != null)
        {
            ai.Initialize(player);
        }
    }
}
