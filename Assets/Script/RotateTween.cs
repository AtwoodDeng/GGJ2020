using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class RotateTween : MonoBehaviour
{

    public float circleTime = 10f;
    public float offset = 10;
    public GameObject childCircle;

    public void Start()
    {
        offset = Random.Range(0, 360f);

        transform.eulerAngles = new Vector3(0, 0, offset);
    }

    private void Update()
    {
        transform.Rotate(new Vector3(0, 0, 360f * Mathf.Deg2Rad / circleTime));
    }
}
