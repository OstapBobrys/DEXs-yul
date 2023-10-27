const path = require('path');
const fs = require('fs');
const solc = require('solc');
const util = require('node:util');

const { TASK_COMPILE_GET_COMPILATION_TASKS } = require('hardhat/builtin-tasks/task-names');

subtask('compile:yul', 'build the Yul files').setAction(async function (args, hre, runSuper) {
  await compile(hre);
});

subtask(TASK_COMPILE_GET_COMPILATION_TASKS, 'hooked to build yul files').setAction(async function (
  args,
  hre,
  runSuper
) {
  let tasks = await runSuper();
  tasks = tasks.concat(['compile:yul']);
  return tasks;
});

async function compile(hre) {
  let artifactsList = [];

  const files = await getYulSources(hre.config.paths);

  for (const file of files) {
    const cwdPath = path.relative(process.cwd(), file);
    console.log(`Compiling ${cwdPath}...`);

    const contractName = path.parse(file).name;

    let abi = [];
    if (config.yulArtifacts.hasOwnProperty(contractName)) {
      abi = hre.config.yulArtifacts[contractName].abi;
    }

    const source = fs.readFileSync(cwdPath, 'utf-8');

    const output = JSON.parse(
      solc.compile(
        JSON.stringify({
          language: 'Yul',
          sources: { 'Target.yul': { content: source } },
          settings: {
            outputSelection: { '*': { '*': ['*'], '': ['*'] } },
            optimizer: {
              enabled: true,
              runs: 200,
              details: {
                inliner: true,
                orderLiterals: true,
                deduplicate: true,
                cse: true,
                yul: true,
                yulDetails: {
                  optimizerSteps: 'uidhfoD[xarrscLMcCTU]uljmulfDnTOcmu',
                },
              },
            },
            viaIR: true,
          },
        })
      )
    );

    if (output.errors && output.errors.length > 1) {
      throw new Error(`compiling error ${path.parse(file).name}: ${util.inspect(output, false, null, true)}`);
    }

    const contractObjects = Object.keys(output.contracts['Target.yul']);
    const bytecode = '0x' + output.contracts['Target.yul'][contractObjects[0]]['evm']['bytecode']['object'];
    const deployed_bytecode =
      '0x' + output.contracts['Target.yul'][contractObjects[0]]['evm']['deployedBytecode']['object'];

    const file_name = path.basename(file);

    const artifact = {
      _format: 'hh-yul-artifact-1',
      contractName: path.parse(file).name,
      sourceName: file_name,
      abi: abi,
      bytecode: bytecode,
      deployedBytecode: deployed_bytecode,
      linkReferences: {},
      deployedLinkReferences: {},
    };

    await hre.artifacts.saveArtifactAndDebugFile(artifact);
    artifactsList.push({ ...artifact, artifacts: [artifact.contractName] });

    hre.artifacts.addValidArtifacts(artifactsList);
  }
}

async function getYulSources(paths) {
  const glob = require('glob');
  const yulFiles = glob.sync(path.join(paths.sources, '**', '*.yul'));

  return yulFiles;
}

module.exports = { compile };
