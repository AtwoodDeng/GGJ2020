using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CellManager : MonoBehaviour
{

    public CellVisual target;


    public void OnGUI()
    {
        if ( GUILayout.Button("Infect") )
        {
            target.SetStateTo(CellVisual.CellState.Infected);
        }
        if (GUILayout.Button("Healthy"))
        {
            target.SetStateTo(CellVisual.CellState.Healthy);
        }
    }
}
